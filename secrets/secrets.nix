let
  user-as-xvi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBQoCNNXZ5H4Z6pSHF+Hqd5M5xlVV4XQ4K9a/kwXV/Mf";
  users = [ user-as-xvi ];

  system-as-xvi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFdwqVFJ7WKWe7LSRKjGIh0d9FpfIqVmogyVl5jvQg8g";
  #system2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzxQgondgEYcLpcPdJLrTdNgZ2gznOHCAxMdaceTUT1";
  #systems = [ system1 system2 ];
in
{
  "secret_as-xvi_ssh_key.age".publicKeys = [ user-as-xvi system-as-xvi ];
  #"secret2.age".publicKeys = users ++ systems;
}  
