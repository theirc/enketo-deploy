Vagrant Testing
========================

Warning: Vagrant is not ideal for testing our Enketo deploy,
because our staging and production servers assume they can access
Redis servers in AWS, but a vagrant server cannot do that (only
AWS EC2 instances can do that).

So, we'd need to add configuration to provision two redis servers
on the vagrant server (or somewhere else) that would be entirely
unnecessary for the real servers.

For now, I haven't bothered. You can use Vagrant to test getting
Enketo installed and started, but it probably won't actually work
due to the lack of Redis servers.  If you really need to test
a working Enketo on Vagrant, I suggest setting up Redis elsewhere
and just updating the Redis URLs in conf/pillar/local.sls.

Starting the VM
------------------------

You can test the provisioning/deployment using `Vagrant <http://vagrantup.com/>`_. This requires
Vagrant 1.7+. The box will be installed if you don't have it already.::

    vagrant up

The general provision workflow is the same as in the previous :doc:`provisioning guide </provisioning>`
so here are notes of the Vagrant specifics.


Provisioning the VM
------------------------

Set your environment variables and secrets in ``conf/pillar/local.sls``. It is OK for this to
be checked into version control because it can only be used on the developer's local machine. To
finalize the provisioning you simply need to run::

    fab vagrant setup_master
    fab vagrant setup_minion:salt-master,enketo -H 127.0.0.1:2222
    fab vagrant deploy

The above command will setup Vagrant to run the full stack. If you want to test only a subset
of the roles you can remove the unneeded roles.


Testing on the VM
------------------------

With the VM fully provisioned and deployed, you can access the VM at the IP address specified in the
``Vagrantfile``, which is 33.33.33.10 by default. Since the Nginx configuration will only listen for the domain name in
``conf/pillar/local.sls``, you will need to modify your ``/etc/hosts`` configuration to view it
at one of those IP addresses. I recommend 33.33.33.10, otherwise the ports in the localhost URL cause
the CSRF middleware to complain ``REASON_BAD_REFERER`` when testing over SSL. You will need to add::

    33.33.33.10 <domain>

where ``<domain>`` matches the domain in ``conf/pillar/local.sls``. For example, let's use
dev.example.com::

    33.33.33.10 dev.example.com

In your browser you can now view https://dev.example.com and see the VM running the full web stack.

Note that this ``/etc/hosts`` entry will prevent you from accessing the true dev.example.com.
When your testing is complete, you should remove or comment out this entry.
