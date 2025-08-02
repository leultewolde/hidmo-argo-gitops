.PHONY: test lint validate dry-run

test: lint validate dry-run

lint:
	yamllint manifests apps projects

validate:
	kubeconform $(shell find manifests apps projects -name '*.yaml')

dry-run:
	k3d cluster create test --wait
	kubectl apply --dry-run=client -k manifests
	k3d cluster delete test
