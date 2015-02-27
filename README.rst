=======
dirvish
=======

This formula makes it easy to configure dirvish to backup your data
and keep them around for some predefined amount of time.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Available states
================

.. contents::
    :local:

``dirvish``
-----------

Install dirvish and configures it according to the pillar data.

Note: dirvish will use ssh (as root) to remote servers. It's up to you to
ensure that the ssh connection works non-interactively. You might have
to configure /root/.ssh/known_hosts and setup SSH keys on the remote
servers.

``Configuration``
=================
See the pillar.example file to have an idea of everything that can
be customized in this formula.
