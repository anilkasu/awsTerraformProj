#Create an empty ECS cluster
resource "aws_ecs_cluster" "restAPICluster" {
  name = "restAPICluster"
}

#create a task definition in the ECS cluster
resource "aws_ecs_task_definition" "ecsRESTAPITask" {
    family = "ecsServiceFamily"

    container_definitions = "${file("containerDefinition.json")}"
    #network_mode = "<default>"   #This is optional value
    cpu = "512"
    memory = "512"
}

#Create a service in the ECS cluster
resource "aws_ecs_service" "ecsRESTAPIService" {
    name = "restAPIService"
    cluster = "${aws_ecs_cluster.restAPICluster.name}"
    task_definition = "${aws_ecs_task_definition.ecsRESTAPITask.arn}"
    desired_count = "2"
    #iam_role = "${aws_iam_role.iamRole.arn}"

    load_balancer {
      #elb_name = "${aws_alb.ecsALB.name}"
      target_group_arn = "${aws_alb_target_group.ecsALBTargetGroup.arn}"
      container_name = "restAPIContainer"
      container_port = "8090"
    }
}
