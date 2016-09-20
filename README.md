# Docker Zookeeper 
This project provides a Dockerized Zookeeper managed by [Exhibitor](https://github.com/Netflix/exhibitor) for running on EC2 instances using [Cloud Compose](http://github.com/cloud-compose).

# Quick Start
To use this project do the following:

1. Create a new Github repo for your configuration (e.g. `my-configs`)
1. Create a directory for zookeeper (e.g. `mkdir my-configs/zookeeper`)
1. Create a sub-directory for your cluster (e.g. `mkdir my-configs/zookeeper/foobar`)
1. Clone this project into your Github repo using subtree merge
1. Copy the docker-zookeeper/cloud-compose/cloud-compose.yml.example to your cluster sub-directory
1. Modify the cloud-compose.yml to fit your needs
1. Create a new cluster using the [Cloud Compose cluster plugin](https://github.com/cloud-compose/cloud-compose-cluster).
```
pip install cloud-compose cloud-compose-cluster
pip freeze -r > requirements.txt
cloud-compose cluster up
```

# FAQ
## How is zookeeper configured?
Zookeeper is run by [Exhibitor](https://github.com/Netflix/exhibitor) which supports both S3 and file based configuration options. In most cases you will want to set the S3_BUCKET and S3_PREFiX environment variables.

The cluster size should almost always be set to 5 with the CLUSTER_SIZE environment variable. The instances should be spread evenly between 3 availability zones. For increased availability you may want to set the cluster size to 7, but there will be some loss of performance. Make sure the CLUSTER_SIZE matches the number of nodes in the cloud-compose.yml file.

You can secure the Exhibitor website by setting the ZK_PASSWORD environment variable. Use this password plus the user name "zk" to login to the Exhibitor website at http://127.0.0.1:8181/exhibitor/v1/ui/index.html. Change the IP address to be one of the cluster nodes.

## How do I safely upgrade the cluster?
Zookeeper uses a quorum protocol so there must be a majority of nodes up for the system to run. You should never replace more than 1 node at a time and should always check that all nodes are healthy before starting or continuing an upgrade. You can see the health at http://127.0.0.1:8181/exhibitor/v1/ui/index.html. Change the IP address to be one of the cluster nodes.

## How do I recreate a cluster?
Exhibitor stores data on S3 so if you want to delete and create the cluster again, you must delete this S3 file. You can find the file by looking at your values for S3_BUCKET and S3_PREFIX in the cloud-compose.yml.

## How do I manage secrets?
Secrets can be configured using environment variables. [Envdir](https://pypi.python.org/pypi/envdir) is highly recommended as a tool for switching between sets of environment variables in case you need to manage multiple clusters.
At a minimum you will need AWS_ACCESS_KEY_ID, AWS_REGION, and AWS_SECRET_ACCESS_KEY. You may also want ZK_SECRET if you want to secure the Exhibitor web console.

## How do I share config files?
Since most of the config files are common between clusters, it is desirable to directly share the configuration between projects. The recommend directory structure is to have docker-zookeeper sub-directory and then a sub-directory for each cluster. For example if I had a test and prod mongodb cluster my directory structure would be:

```
zookeeper/
  docker-zookeeper/cloud-compose/templates/
  test/cloud-compose.yml
  prod/cloud-compose.yml
  templates/
```

The docker-zookeeper directory would be a subtree merge of this Git project, the templates directory would be any common templates that only apply to your mongodb clusters, the the test and prod directories have the cloud-compose.yml files for your two clusters. Regardless of the directory structure, make sure the search_paths in your cloud-compose.yml reflect all the config directories and the order that you want to load the config files.

## How do I create a subtree merge of this project?
A subtree merge is an alternative to a Git submodules for copying the contents of one Github repo into another. It is easier to use once it is setup and does not require any special commands (unlike submodules) for others using your repo.

### Initial subtree merge
To do the initial merge you will need to create a git remote, then merge it into your project as a subtree and commit the changes

```bash
# change to the cluster sub-directory
cd my-configs/zookeeper
# add the git remote
git remote add -f docker-zookeeper git@github.com:washingtonpost/docker-zookeeper.git
# pull in the git remote, but don't commit it
git merge -s ours --no-commit docker-zookeeper/master
# make a directory to merge the changes into
mkdir docker-zookeeper
# actually do the merge
git read-tree --prefix=zookeeper/docker-zookeeper/ -u docker-zookeeper/master
# commit the changes
git commit -m 'Added docker-zookeeper subtree'
```

### Updating the subtree merge
When you want to update the docker-zookeeper subtree use the git pull with the subtree merge strategy

```bash
# Add the remote if you don't already have it
git remote add -f docker-zookeeper git@github.com:washingtonpost/docker-zookeeper.git
# do the subtree merge again
git pull -s subtree docker-zookeeper master
```


