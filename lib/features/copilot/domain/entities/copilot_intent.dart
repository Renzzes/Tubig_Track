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
