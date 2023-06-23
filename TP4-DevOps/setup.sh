echo "TP4-DevOps Execution"

echo "TERRAFORM INIT EXECUTION"
terraform init

echo "=========================================================="
echo "\n\n TERRAFORM APPLY EXECUTION"
terraform apply

chmod 700 mykey.pem

echo "=========================================================="
echo "\n\n TERRAFORM CODE FORMATTING EXECUTION"
terraform fmt

sleep 2

clear

echo "Fin du processus !"

clear

sleep 2

echo "PUBLIC IP ADRESS : "
terraform output public_ip_address