#
# cfn-rh-workstation build file
# Run `make` in the current directory to see targets of interest
#

export APP_VERSION := $(shell git describe --always)

app_exists = @command -v $1 >/dev/null 2>&1 || $(call log_error, "No $1 install found")
log_error = (echo "Error: \x1B[31m$1\x1B[39m" && exit 1)
banner = @echo "---\x1B[34m$1\x1B[39m ---"

define venv_install
	$(call app_exists, "python3")
	$(call banner, "Installing Linters")
	python3 -m venv ./venv
	source ./venv/bin/activate && pip install -r requirements.txt
	@echo "\x1B[31mAttention!\x1B[39m"
	@echo "Run the following command actiate the virtual environment: source ./venv/bin/activate"
endef

about:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(firstword $(MAKEFILE_LIST)) | sort -r | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: about

deploy:
	$(call app_exists, "python3")
	@python3 scripts/automation/deploy.py \
		--config_path=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))config \
		--environment=$(ENV)
.PHONY: deploy

lint: lint-cfn lint-python lint-yaml ## Run all lint checks
.PHONY: lint

lint-cfn: ##   > Check template with just cfn-lint
	$(call app_exists, "cfn-lint")
	$(call banner, "CloudFormation Lint Checks")
	@find cloudformation -name "*.yaml" -exec cfn-lint {} \;
.PHONY: cfn-lint

lint-python: ##   > Check Python code with flake8
	$(call app_exists, "flake8")
	$(call banner, "Python Lint Checks")
	@find "scripts/automation" -name "*.py" -exec flake8 {} \;

lint-yaml: ##   > Check template with just yamllint
	$(call app_exists, "yamllint")
	$(call banner, "YAML Lint Checks")
	@find cloudformation -name "*.yaml" -exec yamllint {} \;
.PHONY: yaml-lint

lint-install: ##   > Install Python virtual env with linters
	@echo "Installing Python3 virtual env and linters. Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ] || $(call log_error, "Operation cancelled")
	$(call venv_install, "")
.PHONY: lint-install
