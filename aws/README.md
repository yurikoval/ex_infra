# AWS

What this does:

- Spins up a single ec2 instance
- Creates DNS routing to said instance
- Clones app repo into instance
- Copies required config files using `scp`

# Prerequisites

1. Install required terraform plugins `terraform init`

2. Set up your custom AMI with Erlang and Elixir installed for faster builds.

Using Amazon's Linux instance `ami-0ce71448843cb18a1`:

```shell
# as root, update everything and install required libraries
yum update -y
yum install ncurses-devel openssl-devel tmux -y
yum groupinstall "Development Tools" -y
```

```shell
# as ec2-user
# install asdf
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.4
echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bashrc
echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc

# install elixir and erlang
asdf plugin-add erlang
asdf plugin-add elixir

asdf install erlang 22.0.7
asdf install elixir 1.9.2

mix local.hex --force
mix local.rebar --force
```

2. Save this instance and record the AMI id into `default_ami` in `variables.tf` (also, change `ami_owner_id` to `self`)

3. Create Route 53 domain and set `route53_public_zone_id` to that id.

4. Download and save a `.pem` file used for ssh-ing into the machine to ` ~/.ssh/`

4. _(optional)_ configure your SSH to allow faster logins

```
Host app
  HostName app.example.com
  IdentityFile ~/.ssh/ec2.pem
  User ec2-user
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
```

# Usage

## Boot

1. `terraform apply`
2. `ssh app`

## Teardown

`terraform destroy`

# TODO

- ditch git and build app with distillery/release
- Download CI's production build artifacts and copy those into the instance.
