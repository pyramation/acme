
def:
	docker build -t "pyramation/acme" .

ssh:
	docker run -it pyramation/acme /bin/sh

push:
	docker push pyramation/acme