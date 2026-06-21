{ self, lib, ... }: with lib; let
  inherit (self) mkNameClusterPWD;

  mkNameClusterTokenID     = cluster: token_id: concatStringsSep "_" [ "PVE" "TOKEN" "ID"     (toUpper cluster.name) (toUpper token_id)];
  mkNameClusterTokenSecret = cluster: token_id: concatStringsSep "_" [ "PVE" "TOKEN" "SECRET" (toUpper cluster.name) (toUpper token_id)];

  mkTaskIssueToken = input: cluster: let
    # ansible local variable name conventions
    ticket       = "ticket";
    token        = "token" ;
    # ansible global variable name conventions
    token_id     = mkNameClusterTokenID     cluster input.api_token_id; 
    token_secret = mkNameClusterTokenSecret cluster input.api_token_id; 
  in [
    # 1.Login to proxmox with password
    {
      name = "Login to proxmox with password";
      "ansible.builtin.uri" = {
        url    = "https://${cluster.api_host}:${cluster.api_port}/api2/json/access/ticket";
        method = "POST";

        body_format = "form-urlencoded";
        body = {
          username = "${input.api_user}";
          password = "{{ ${mkNameClusterPWD cluster input.api_user} }}";
        };
        validate_certs = if cluster.validate_certs then "yes" else "no";
      };
      register      = "${ticket}";
      ignore_errors = true;
    }
    # 2.Remove previous token if exists
    {
      name = "Remove previous token if exists";
      "ansible.builtin.uri" = {
        url    = "https://${cluster.api_host}:${cluster.api_port}/api2/json/access/users/${input.api_user}/token/${input.api_token_id}"; 
        method = "DELETE";
        headers = {
          Cookie = ''
            PVEAuthCookie={{ ${ticket}.json.data.ticket }}
          '';
          CSRFPreventionToken = "{{ ${ticket}.json.data.CSRFPreventionToken }}";
        };

        validate_certs = if cluster.validate_certs then "yes" else "no";
        status_code = 200;
      };
      ignore_errors = true;
    }
    # 3.Issue token with REST API
    {
      name = "Issue token ${input.api_token_id}";
      "ansible.builtin.uri" = {
        url    = "https://${cluster.api_host}:${cluster.api_port}/api2/json/access/users/${input.api_user}/token/${input.api_token_id}"; 
        method = "POST";
        headers = {
          Cookie = ''
            PVEAuthCookie={{ ${ticket}.json.data.ticket }}
          '';
          CSRFPreventionToken = "{{ ${ticket}.json.data.CSRFPreventionToken }}";
        };

        body_format = "json";
        body = {
          privsep = input.privilege_seperation or true;
          expire  = input.expire               or 0;
          comment = input.comment              or "";
        };

        validate_certs = if cluster.validate_certs then "yes" else "no";
        status_code = 200;
      };
      register = "${token}";
    }
    # 4.Save token as variable
    {
      name = "Save token ${input.api_token_id} as variable";
      "ansible.builtin.set_fact" = {
        ${token_id}     = "{{ ${token}.json.data['full-tokenid'] }}";
        ${token_secret} = "{{ ${token}.json.data.value }}";
      };
    }
  ];

  root_token_id = "nixus";

  mkNameClusterRootTokenID     = cluster: mkNameClusterTokenID     cluster root_token_id;
  mkNameClusterRootTokenSecret = cluster: mkNameClusterTokenSecret cluster root_token_id;

  mkTaskIssueRootToken = mkTaskIssueToken { api_user = "root@pam"; api_token_id = root_token_id; privilege_seperation = false; };

in {
  # inherit mkNameClusterTokenID;
  # inherit mkNameClusterTokenSecret;
  # inherit mkTaskIssueToken;

  inherit mkNameClusterRootTokenID;
  inherit mkNameClusterRootTokenSecret;
  inherit mkTaskIssueRootToken;
}
