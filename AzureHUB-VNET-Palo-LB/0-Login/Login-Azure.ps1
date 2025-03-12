#Written by LongTechnet
#
#Subscription Name 
$SubscriptionName = "sub-1"

# To login to Azure 
Login-AzAccount 

# To select a default subscription for your current session
Get-AzSubscription -SubscriptionName $SubscriptionName | Select-AzSubscription

