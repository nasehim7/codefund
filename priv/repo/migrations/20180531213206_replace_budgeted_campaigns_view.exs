defmodule CodeFund.Repo.Migrations.ReplaceBudgetedCampaignsView do
  use Ecto.Migration

  def up do
    execute "DROP VIEW budgeted_campaigns;"
    execute """
    CREATE VIEW budgeted_campaigns AS
      SELECT campaigns.id AS campaign_id,
      (
          SELECT COALESCE(SUM(impressions.revenue_amount), 0) FROM impressions
              WHERE campaign_id = campaigns.id
              AND inserted_at::date = now()::date
      ) AS day_spend,
      (
          SELECT COALESCE((campaigns.budget_daily_amount - COALESCE(SUM(impressions.revenue_amount), 0)), 0) FROM impressions
              WHERE campaign_id = campaigns.id
              AND inserted_at::date = now()::date
      ) AS day_remain,
      (
          SELECT COALESCE(SUM(impressions.revenue_amount), 0) FROM impressions
              WHERE campaign_id = campaigns.id
      ) AS total_spend,
      (
          SELECT COALESCE((campaigns.budget_total_amount - COALESCE(SUM(impressions.revenue_amount), 0)), 0) FROM impressions
              WHERE campaign_id = campaigns.id
      ) AS total_remain
      FROM campaigns
    ;
    """
  end

  def down do
    execute "DROP VIEW budgeted_campaigns;"
    execute """
    CREATE VIEW budgeted_campaigns AS
      SELECT campaigns.id AS campaign_id,
      (
          SELECT COALESCE(SUM(clicks.revenue_amount), 0) FROM clicks
              WHERE is_bot = false
              AND is_duplicate = false
              AND is_fraud = false
              AND campaign_id = campaigns.id
              AND inserted_at::date = now()::date
      ) AS day_spend,
      (
          SELECT COALESCE((campaigns.budget_daily_amount - COALESCE(SUM(clicks.revenue_amount), 0)), 0) FROM clicks
              WHERE is_bot = false
              AND is_duplicate = false
              AND is_fraud = false
              AND campaign_id = campaigns.id
              AND inserted_at::date = now()::date
      ) AS day_remain,
      (
          SELECT COALESCE(SUM(clicks.revenue_amount), 0) FROM clicks
              WHERE is_bot = false
              AND is_duplicate = false
              AND is_fraud = false
              AND campaign_id = campaigns.id
              AND inserted_at::date >= DATE_TRUNC('month', now())::date
      ) AS month_spend,
      (
          SELECT COALESCE((campaigns.budget_monthly_amount - COALESCE(SUM(clicks.revenue_amount), 0)), 0) FROM clicks
              WHERE is_bot = false
              AND is_duplicate = false
              AND is_fraud = false
              AND campaign_id = campaigns.id
              AND inserted_at::date >= DATE_TRUNC('month', now())::date
      ) AS month_remain,
      (
          SELECT COALESCE(SUM(clicks.revenue_amount), 0) FROM clicks
              WHERE is_bot = false
              AND is_duplicate = false
              AND is_fraud = false
              AND campaign_id = campaigns.id
      ) AS total_spend,
      (
          SELECT COALESCE((campaigns.budget_total_amount - COALESCE(SUM(clicks.revenue_amount), 0)), 0) FROM clicks
              WHERE is_bot = false
              AND is_duplicate = false
              AND is_fraud = false
              AND campaign_id = campaigns.id
      ) AS total_remain
      FROM campaigns
    ;
    """
  end
end
