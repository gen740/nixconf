{
  description = "A secrets template for gen740";

  outputs = { ... }: {
    secrets = {
      openssh.authorizedKeys.keys = [ ];
      services.gitlab.databasePasswordFile = "";
      services.gitlab.initialRootPassword = "";
      services.gitlab.secrets.secret = "xxxxxxx";
      services.gitlab.secrets.otpsecret = "xxxxxxx";
      services.gitlab.secrets.dbsecret = "xxxxxxx";
    };
  };
}
