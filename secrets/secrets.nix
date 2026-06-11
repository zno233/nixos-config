let
  zno = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJpsj1Us0BcP9eMcL77x+OHZZRnge5RimbGS18DhXJcq";
  users = [ zno ];

  honor-laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJnG/gpK+1Bg3VqdIQtWKqq/PJB4n2UHRJfjTlriuw4N";
  systems = [ honor-laptop ];
in
{
  "deepseek-token.age".publicKeys = [
    zno
    honor-laptop
  ];
  # "secret2.age".publicKeys = users ++ systems;
  # "armored-secret.age" = {
  #   publicKeys = [ zno ];
  #   armor = true;
  # };
}
