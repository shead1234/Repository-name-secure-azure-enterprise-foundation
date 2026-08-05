targetScope = 'subscription'

@description('Name of the project cost budget.')
param budgetName string

@description('Monthly budget amount in USD.')
@minValue(1)
param budgetAmount int = 20

@description('First day of the budget period.')
param budgetStartDate string

@description('End date of the budget period.')
param budgetEndDate string

@description('Email address that receives budget notifications.')
@secure()
param contactEmail string

@description('Resource group included in the budget.')
param resourceGroupName string

resource projectBudget 'Microsoft.Consumption/budgets@2023-11-01' = {
  name: budgetName
  properties: {
    amount: budgetAmount
    category: 'Cost'
    timeGrain: 'Monthly'
    timePeriod: {
      startDate: budgetStartDate
      endDate: budgetEndDate
    }
    filter: {
      dimensions: {
        name: 'ResourceGroupName'
        operator: 'In'
        values: [
          resourceGroupName
        ]
      }
    }
    notifications: {
      ActualCost80Percent: {
        enabled: true
        operator: 'GreaterThanOrEqualTo'
        threshold: 80
        thresholdType: 'Actual'
        contactEmails: [
          contactEmail
        ]
      }
      ForecastedCost100Percent: {
        enabled: true
        operator: 'GreaterThanOrEqualTo'
        threshold: 100
        thresholdType: 'Forecasted'
        contactEmails: [
          contactEmail
        ]
      }
    }
  }
}

output budgetName string = projectBudget.name
output budgetResourceId string = projectBudget.id
