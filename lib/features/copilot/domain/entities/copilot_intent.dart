enum CopilotIntent {
  // ── Savings & Profit ─────────────────────────────────────────────────────
  getSavings,
  getProfit,
  getYearlyProfit,
  getCompareSavings,
  getBestMonth,
  getHighestRevenueMonth,

  // ── Customers ─────────────────────────────────────────────────────────────
  getOverdueCustomers,
  getTopCustomers,
  getInactiveCustomers,
  getRevenueByCustomer,
  getCustomerStatement,
  getCustomerProfile,
  getSpecificCustomerBalance,
  getSpecificCustomerBottles,
  getCustomersWithDeposits,
  getCustomersWithBottlesAndOverdue,
  getCustomerMostDeliveries,
  getCustomersNeedingReconciliation,
  getNeverVerifiedCustomers,
  getCustomersWithMissingBottles,
  getCustomersWithOverdueBalances,
  getTotalCustomerOwnedBottles,
  getCustomerStatementSummary,

  // ── Walk-In Operations (v1.6.0) ───────────────────────────────────────────
  getWalkInRevenue,
  getWalkInRefillsThisMonth,
  getWalkInExchangesThisMonth,
  compareWalkInsVsDeliveries,

  // ── Bottles & Inventory ───────────────────────────────────────────────────
  getMissingBottles,
  getDamagedBottles,
  getInventoryStatus,
  getCustomerBottles,
  getCustomerBalance,
  getMonthlyBottlePurchases,

  // ── Deliveries ────────────────────────────────────────────────────────────
  getDeliverySummary,
  getTodayDeliveries,
  getTomorrowDeliveries,
  getUpcomingDeliveries,
  getWeekDeliveries,

  // ── Deposits & Payments ───────────────────────────────────────────────────
  getDepositStatus,
  getTotalReceivables,

  // ── Expenses ──────────────────────────────────────────────────────────────
  getMonthlyExpenses,

  // ── Audit ─────────────────────────────────────────────────────────────────
  getAuditStatus,

  // ── Composite ─────────────────────────────────────────────────────────────
  getFollowUps,
  getHealthCheck,

  // ── Fallback ──────────────────────────────────────────────────────────────
  unknown,
}
