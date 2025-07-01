# env.nu
#
# Installed by:
# version = "0.105.1"
#
# Previously, environment variables were typically configured in `env.nu`.
# In general, most configuration can and should be performed in `config.nu`
# or one of the autoload directories.
#
# This file is generated for backwards compatibility for now.
# It is loaded before config.nu and login.nu
#
# See https://www.nushell.sh/book/configuration.html
#
# Also see `help config env` for more options.
#
# You can remove these comments if you want or leave
# them for future reference.


def set_aws_profile [name: string] {
  $env.AWS_PROFILE = $name
  $"Switched to profile: ($name)"
}

def assume-admin-role [] {
  let mfa = (input "🔐 Enter MFA token: ")
  let raw = (do {
    aws sts assume-role --profile staging-aws --role-arn arn:aws:iam::956919315810:role/k8sAdmin --role-session-name temp-session --serial-number arn:aws:iam::956919315810:mfa/piotrptak --token-code $mfa
  })
  let creds = ($raw | from json)
  $env.AWS_ACCESS_KEY_ID = $creds.Credentials.AccessKeyId
  $env.AWS_SECRET_ACCESS_KEY = $creds.Credentials.SecretAccessKey
  $env.AWS_SESSION_TOKEN = $creds.Credentials.SessionToken
  print "✅ Assumed k8sAdmin role with temporary credentials"
}

def parse-line-protocol [] {
  lines
  | each {|line|
      echo $"line: ($line)"

      let parts = ($line | split column ' ' --collapse-empty)
      echo $"parts: ($parts.0.column1)"
  }
}

