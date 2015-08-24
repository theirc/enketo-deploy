Server Provisioning
========================


Overview
------------------------

IRC Enketo is deployed on the following stack.

- OS: Ubuntu 14.04 LTS
- Nginx
- Enketo

Two redis servers are also required. This deploy framework assumes
they've already been set up (e.g. on Amazon Elasticache or another server)
and requires configuring their URLs in the project environment
configuration.

This deploy framework listens only on port 443 (SSL)*, but just
uses a self-signed certificate generated at deploy time. The assumption
is that a load balancer is in front of this server, receiving incoming
connections on SSL with a valid certificate for whatever domain name
the service is running under.

(* Actually it also listens on 80, but always responds on port 80 with
a redirect to the same URL on https:.)


Salt Master
------------------------

Each project needs a Salt Master per environment (staging, production, etc).
The master is configured with Fabric. ``env.master`` should be set to the IP 
of this server in the environment where it will be used::
    
    @task
    def staging():
        ...
        env.master = <ip-of-master>

You will need to be able to connect to the server as a root user.
How this is done will depend on where the server is hosted.
VPS providers such as Linode will give you a username/password combination. Amazon's
EC2 uses a private key. These credentials will be passed as command line arguments.::

    # Template of the command
    fab -u <root-user> <environment> setup_master
    # Example of provisioning 33.33.33.10 as the Salt Master for staging
    fab -u root staging setup_master

This will install salt-master and update the master configuration file. The master will use a
set of base states from https://github.com/caktus/margarita checked out
at ``/srv/margarita``.

As part of the master setup, a new GPG public/private key pair is generated. The private
key remains on the master but the public version is exported and fetched back to the
developer's machine. This will be put in ``conf/<environment>.pub.gpg``. This will
be used by all developers to encrypt secrets for the environment and needs to be
committed into the repo.


Pillar Setup
------------------------

You should update
``conf/pillar/<environment>.sls`` for the environment.

Set ``project_name`` and ``python_version`` in ``conf/pillar/project.sls``.

For the environment you want to setup you will need to set the ``domain`` in
``conf/pillar/<environment>.sls``.

You will also need add the developer's user names and SSH keys to ``conf/pillar/devs.sls``. Each
user record (under the parent ``users:`` key) should match the format::

    example-user:
      public_key:
       - ssh-rsa <Full SSH Public Key would go here>

Additional developers can be added later, but you will need to create at least one user for
yourself.

The following pillar variables are REQUIRED:

margarita_version: "git revision/tag/branch for version of Margarita to use"

enketo:
  name: "Human-readable name for this service, e.g. KoBoCat or IRC Enketo"
  express_version:  "Git revision/branch/tag to use from https://github.com/enketo/enketo-express (do NOT include origin/)"

support_email:  "email@some_domain"

redis:
  main:
     host: "host of main redis server/database"
     port: "port of main redis server/database"
     password: "password of main redis server/database"
  cache:
     host: "host of cache redis server/database"
     port: "port of cache redis server/database"
     password: "password of cache redis server/database"
secrets:
  enketo_api_key: "API key for the kobo or Ona server to use when accessing this server"
  enketo_encryption_key: "random password-like string, never change after initial deploy"

These are OPTIONAL:

ga:
  ua: "google analytics UA"
  domain: "google analytics domain"


Managing Secrets
------------------------

Secret information such as passwords and API keys must be encrypted before being added
to the pillar files. As previously noted, provisioning the master for the environment
generates a public GPG key which is added to repo under ``conf/<environment>.pub.gpg``
To encrypt a new secret using this key, you can use the ``encrypt`` fab command::
  
    # Example command
    fab <environment> encrypt:<key>=<secret-value>
    # Encrypt the SECRET_KEY for the staging environment
    fab staging encrypt:SECRET_KEY='thisismysecretkey'

The output of this command will look something like::

    "SECRET_KEY": |-
      -----BEGIN PGP MESSAGE-----
      Version: GnuPG v1.4.11 (GNU/Linux)

      hQEMA87BIemwflZuAQf/XDTq6pdZsS07zw88lvGcWbcy5pj5CLueVldE+NLAHilv
      YaFb1qPM1W+yrnxFQgsapcHUM82ULkXbMskYoK5qp5Or2ujwzAVRpbSrFTq19Frz
      sasFTPNNREgThLB8oyQIHN2XfqSvIqi6RkqXGf+eQDXLyl9Guu+7EhFtW5PJRo3i
      BSBVEuMi4Du60uAssQswNuit7lkEqxFprZDb9aHmjVBi+DAipmBuJ+FIyK0ePFAf
      dVfp/Es/y4/hWkM7TXDw5JMFtVfCo6Dm1LE53N339eJX01w19exB/Sek6HVwDsL4
      d45c1dm7qBiXN0zO8Yadhm520J0H9NcIPO47KyRkCtJAARsY5eu8cHxYW4DcYWLu
      PRr2CLuI8At1Q2KqlRgdEm17lV5HOEcMoT1SyvMzaWOnbpul5PoLCAebJ0zcJZT5
      Pw==
      =V1Uh
      -----END PGP MESSAGE-----

where ``SECRET_KEY`` would be replace with the key you were trying to encrypt. This
block of text should be added to the environment pillar ``conf/pillar/<environment>.sls``
under the ``secrets`` block::

    secrets:
      "SECRET_KEY": |-
        -----BEGIN PGP MESSAGE-----
        Version: GnuPG v1.4.11 (GNU/Linux)

        hQEMA87BIemwflZuAQf/XDTq6pdZsS07zw88lvGcWbcy5pj5CLueVldE+NLAHilv
        YaFb1qPM1W+yrnxFQgsapcHUM82ULkXbMskYoK5qp5Or2ujwzAVRpbSrFTq19Frz
        sasFTPNNREgThLB8oyQIHN2XfqSvIqi6RkqXGf+eQDXLyl9Guu+7EhFtW5PJRo3i
        BSBVEuMi4Du60uAssQswNuit7lkEqxFprZDb9aHmjVBi+DAipmBuJ+FIyK0ePFAf
        dVfp/Es/y4/hWkM7TXDw5JMFtVfCo6Dm1LE53N339eJX01w19exB/Sek6HVwDsL4
        d45c1dm7qBiXN0zO8Yadhm520J0H9NcIPO47KyRkCtJAARsY5eu8cHxYW4DcYWLu
        PRr2CLuI8At1Q2KqlRgdEm17lV5HOEcMoT1SyvMzaWOnbpul5PoLCAebJ0zcJZT5
        Pw==
        =V1Uh
        -----END PGP MESSAGE-----

The ``Makefile`` has a make command for generating a random secret. By default
this is 32 characters long but can be adjusted using the ``length`` argument.::

    make generate-secret
    make generate-secret length=64

This can be combined with the above encryption command to generate a random
secret and immediately encrypt it.::

    fab staging encrypt:SECRET_KEY=`make generate-secret length=64`

By default the project will use the ``SECRET_KEY`` if it is set. You can also
optionally set a ``DB_PASSWORD``. If not set, you can only connect to the database
server on localhost so this will only work for single server setups.


Environment Variables
------------------------

Other environment variables which need to be configured but aren't secret can be added
to the ``env`` dictionary in ``conf/pillar/<environment>.sls`` without encryption.

  # Additional public environment variables to set for the project
  env:
    FOO: BAR

For instance the default layout expects the cache server to listen at ``127.0.0.1:11211``
but if there is a dedicated cache server this can be changed via ``CACHE_HOST``. Similarly
the ``DB_HOST/DB_PORT`` defaults to ``''/''``::

  env:
    DB_HOST: 10.10.20.2
    CACHE_HOST: 10.10.20.1:11211


Setup Checklist
------------------------

To summarize the steps above, you can use the following checklist

- Developer user names and SSH keys have been added to ``conf/pillar/devs.sls``
- Project name has been set in ``conf/pillar/project.sls``
- Environment domain name has been set in ``conf/pillar/<environment>.sls``
- Environment secrets have been set in ``conf/pillar/<environment>.sls``


Provision a Minion
------------------------

Once you have completed the above steps, you are ready to provision a new server
for a given environment. Again you will need to be able to connect to the server
as a root user. This is to install the Salt Minion which will connect to the Master
to complete the provisioning. To setup a minion you call the Fabric command::

    fab <environment> setup_minion:<roles> -H <ip-of-new-server> -u <root-user>
    fab staging setup_minion:salt-master,enketo -H  33.33.33.10 -u root

The available roles are ``salt-master`` and ``enketo``. If you are running everything on
a single server, you need to enable all roles.

Additional roles can be added later to a server via ``add_role``. Note that there is no
corresponding ``delete_role`` command because deleting a role does not disable the services or
remove the configuration files of the deleted role::

    fab add_role:enketo -H  33.33.33.10

After that you can run the deploy/highstate to provision the new server::

    fab <environment> deploy

The first time you run this command, it may complete before the server is set up.
It is most likely still completing in the background. If the server does not become
accessible or if you encounter errors during the process, review the Salt logs for
any hints in ``/var/log/salt`` on the minion and/or master. For more information about
deployment, see the `server setup </server-setup>` documentation.

The initial deployment will create developer users for the server so you should not
need to connect as root after the first deploy.


Optional Configuration
------------------------

The default template contains setup to help manage common configuration needs which
are not enabled by default.


HTTP Auth
________________________

The ``<environment>.sls`` can also contain a section to enable HTTP basic authentication. This
is useful for staging environments where you want to limit who can see the site before it
is ready. This will also prevent bots from crawling and indexing the pages. To enable basic
auth simply add a section called ``http_auth`` in the relevant ``conf/pillar/<environment>.sls``.
As with other passwords this should be encrypted before it is added::

    # Example encryption
    fab <environment> encrypt:<username>=<password>
    # Encrypt admin/abc123 for the staging environment
    fab staging encrypt:admin=abc123

This would be added in ``conf/pillar/<environment>.sls`` under ``http_auth``:

    http_auth:
      "admin": |-
        -----BEGIN PGP MESSAGE-----
        Version: GnuPG v1.4.11 (GNU/Linux)

        hQEMA87BIemwflZuAQf+J4+G74ZSfrUPRF7z7+DPAmhBlK//A6dvplrsY2RsfEE4
        Tfp7QPrHZc5V/gS3FXvlIGWzJOEFscKslzgzlccCHqsNUKE96qqnTNjsIoGOBZ4z
        tmZV2F3AXzOVv4bOgipKIrjJDQcFJFjZKMAXa4spOAUp4cyIV/AQBu0Gwe9EUkfp
        yXD+C/qTB0pCdAv5C4vyl+TJ5RE4fGnuPsOqzy4Q0mv+EkXf6EHL1HUywm3UhUaa
        wbFdS7zUGrdU1BbJNuVAJTVnxAoM+AhNegLK9yAVDweWK6pApz3jN6YKfVLFWg1R
        +miQe9hxGa2C/9X9+7gxeUagqPeOU3uX7pbUtJldwdJBAY++dkerVIihlbyWOkn4
        0HYlzMI27ezJ9WcOV4ywTWwOE2+8dwMXE1bWlMCC9WAl8VkDDYup2FNzmYX87Kl4
        9EY=
        =PrGi
        -----END PGP MESSAGE-----

This should be a list of key/value pairs. The keys will serve as the usernames and
the values will be the password. As with all password usage please pick a strong
password.


SSL
________________________

The default configuration expects the site to run under HTTPS everywhere. However, unless
an SSL certificate is provided, the site will use a self-signed certificate. To include
a certificate signed by a CA you must update the ``ssl_key`` and ``ssl_cert`` pillars
in the environment secrets. The ``ssl_cert`` should contain the intermediate certificates
provided by the CA. It is recommended that this pillar is only pushed to servers
using the ``balancer`` role. See the ``secrets.ex`` file for an example.

You can use the below OpenSSL commands to generate the key and signing request::

  # Generate a new 2048 bit RSA key
  openssl genrsa -out {{ project_name }}.key 2048
  # Make copy of the key with the passphrase
  cp {{ project_name }}.key {{ project_name }}.key.secure
  # Remove any passphrase
  openssl rsa -in {{ project_name }}.secure -out {{ project_name }}.key
  # Generate signing request
  openssl req -new -key {{ project_name }}.key -out {{ project_name }}.csr

The last command will prompt you for information for the signing request including
the organization for which the request is being made, the location (country, city, state),
email, etc. The most important field in this request is the common name which must
match the domain for which the certificate is going to be deployed (i.e example.com).

This signing request (.csr) will be handed off to a trusted Certificate Authority (CA) such as
StartSSL, NameCheap, GoDaddy, etc. to purchase the signed certificate. The contents of
the *.key file will be added to the ``ssl_key`` pillar and the signed certificate
from the CA will be added to the ``ssl_cert`` pillar. These should be encrypted using
the same proceedure as with the private SSH deploy key.
