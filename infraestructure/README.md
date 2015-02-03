# Infraestructure

This project handles analiceme's deploys. It relays on `./ssh/config`, so your server's information is safe on your `$HOME` directory.

To deploy **aphrodite**:

    fab -H aphrodite deploy_aphrodite
    fab -H aphrodite deploy_schedulers

to deploy **hephaestus**:

    fab -Hworker1,worker2,worker3 deploy_hephaestus

You will need to have [fabric](http://www.fabfile.org/) already installed on your computer.
