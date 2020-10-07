# Require environment variables on initialisation
# https://github.com/bkeepers/dotenv#required-keys
Dotenv.require_keys if defined?(Dotenv)
Dotenv.require_keys("AWS_ROLE", "DALMATIAN_AWS_ACCOUNT_ID", "HIDE_SECRETS_BY_DEFAULT")
