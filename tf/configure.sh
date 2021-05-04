#!/bin/bash

set -e

AKS_CLUSTER_NAME=$(terraform output cluster_name)
AKS_CLUSTER_RG=$(terraform output cluster_rg)
LOG_WS_ID=$(terraform output log_ws_id)
ACR_NAME=$(terraform output acr_name)

az aks enable-addons -a monitoring -n "$AKS_CLUSTER_NAME" -g "$AKS_CLUSTER_RG" --workspace-resource-id "$LOG_WS_ID" --debug
az aks update -n "$AKS_CLUSTER_NAME" -g "$AKS_CLUSTER_RG" --attach-acr "$ACR_NAME" --debug