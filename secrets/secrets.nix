let
  master-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE8aX4b0tjEhWpZbyNgyt3aySQ1y+zphxwUbwVB39tS2";

  user-xvi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGYHQmlbTpSyx7ormup+K+jmfzZbfCkLzklzTcoD45Ew";
  user-as-xvi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBQoCNNXZ5H4Z6pSHF+Hqd5M5xlVV4XQ4K9a/kwXV/Mf";
  users = [ user-xvi user-as-xvi ];

  system-as-xvi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFdwqVFJ7WKWe7LSRKjGIh0d9FpfIqVmogyVl5jvQg8g";
  system-nixos-vm = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGSaiEZxP1i+yYtJ63hJkbrK/85u6/mHe3hbMKVxKMtp";
  
  #system2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzxQgondgEYcLpcPdJLrTdNgZ2gznOHCAxMdaceTUT1";
  systems = [ system-as-xvi system-nixos-vm ];
in
{
  "secret_as-xvi_ssh_key.age".publicKeys = [ master-key ] ++ users ++ systems;
  "secret_xvi_ssh_key.age".publicKeys = [ master-key ] ++ users ++ systems;
  #"secret2.age".publicKeys = users ++ systems;
}
