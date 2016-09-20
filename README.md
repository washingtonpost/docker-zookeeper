# docker-zookeeper
To check the health of a cluster go to http://127.0.0.1:8181/exhibitor/v1/ui/index.html. Change the IP address to be one of the cluster nodes.
Make sure to check the health after replacing a node before going on to the next node. Otherwise you could lose all the data on the cluster.

If you create a cluster it saves state to an s3 file called exhibitor-$CLUSTER_NAME to the s3 bucket specified. If you want to recreate the same cluster you must delete that s3 file first or the nodes won't come up.


