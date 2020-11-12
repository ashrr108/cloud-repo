#!/bin/bash

export IMAGE_FAMILY="ubuntu-1804-lts"
export ZONE="us-central1-a"
export MASTER_INSTANCE="roost-controlplane"
export INSTANCE_TYPE="e2-medium"
export IMAGE_PROJECT="ubuntu-os-cloud"
export WORKER_INSTANCE="roost-worker"

SSH=ssh
GCLOUD="gcloud compute"

create_instances(){

    gcloud compute instances create $MASTER_INSTANCE \
            --zone=$ZONE \
            --image-project=$IMAGE_PROJECT \
            --image-family=$IMAGE_FAMILY \
            --machine-type=$INSTANCE_TYPE \
            --boot-disk-size=20GB \

    gcloud compute scp $HOME/docker.sh $MASTER_INSTANCE:~
    gcloud compute scp $HOME/k8s.sh $MASTER_INSTANCE:~

    $GCLOUD $SSH $MASTER_INSTANCE --zone $ZONE --command 'chmod 700 docker.sh'
    $GCLOUD $SSH $MASTER_INSTANCE --zone $ZONE --command 'chmod 700 k8s.sh'
    $GCLOUD $SSH $MASTER_INSTANCE --zone $ZONE --command './docker.sh'
    $GCLOUD $SSH $MASTER_INSTANCE --zone $ZONE --command './k8s.sh'

    mv ~/.ssh/google_compute_engine.pub ~/.ssh/google_compute_engine.pub.old
    mv ~/.ssh/google_compute_engine ~/.ssh/google_compute_engine.old

    gcloud compute instances create $WORKER_INSTANCE \
            --zone=$ZONE \
            --image-project=$IMAGE_PROJECT \
            --image-family=$IMAGE_FAMILY \
            --machine-type=$INSTANCE_TYPE \
            --boot-disk-size=20GB \

    gcloud compute scp $HOME/docker.sh $WORKER_INSTANCE:~
    gcloud compute scp $HOME/k8s_worker.sh $WORKER_INSTANCE:~
    $GCLOUD $SSH $WORKER_INSTANCE --zone $ZONE --command 'chmod 700 docker.sh'
    $GCLOUD $SSH $WORKER_INSTANCE --zone $ZONE --command 'chmod 700 k8s_worker.sh'

    $GCLOUD $SSH $WORKER_INSTANCE --zone $ZONE --command './docker.sh'
    $GCLOUD $SSH $WORKER_INSTANCE --zone $ZONE --command './k8s_worker.sh'

    joincmd=`$GCLOUD $SSH $MASTER_INSTANCE --zone $ZONE --command 'sudo kubeadm token create --print-join-command 2>/dev/null' | sed "s/$(printf '\r')\$//"`
    echo $joincmd
    $GCLOUD $SSH $WORKER_INSTANCE --zone $ZONE --command "sudo $joincmd"

    $GCLOUD $SSH $MASTER_INSTANCE --zone $ZONE --command 'kubectl get nodes'
}

start_instance(){
    $GCLOUD instances start $MASTER_INSTANCE --zone $ZONE
    $GCLOUD instances start $WORKER_INSTANCE --zone $ZONE
}

stop_instance(){
    $GCLOUD instances stop $MASTER_INSTANCE --zone $ZONE
    $GCLOUD instances stop $WORKER_INSTANCE --zone $ZONE
}

terminate_instance(){
    $GCLOUD instances delete $MASTER_INSTANCE --zone $ZONE
    $GCLOUD instances delete $WORKER_INSTANCE --zone $ZONE
}

ACTION="create"

main() {
    case $ACTION in
        create)
            echo "creating a master and worker instances"
            create_instances
            ;;
        start)
            echo "starting the instance"
            start_instance
            ;;
        stop)
            echo "stopping the instance"
            stop_instance
            ;;
        terminate)
            echo "deleting the instances"
            terminate_instance
            ;;
    esac
    echo
}

main $*
