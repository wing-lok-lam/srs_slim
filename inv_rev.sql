
  select 
    t1.string as sales_channel_name,
    t2.string as account_name, 
    account_id, 
    currency,
    site_name, 
    site_section,
    ad_unit, 
    delivery_medium,
    screen_location,
    ad_unit_size,
    content_topic,
    country,
    requests,
    impressions,
    billable_impressions,
    clicks,
    total_conversions,
    gross_revenue,
    publisher_revenue,
    network_revenue,
    if((grp_cnt=guaranteed_rev_cnt), guaranteed_rev, null) as guaranteed_rev,
    publisher_billable_eRPM,
    network_billable_eRPM,
    publisher_eRPM, 
    network_eRPM 
  from
    (select
      t_sales_channel_name,
      t_account_name,
      if(account_id<0,null,account_id) as account_id,
      currency_code as currency,
      site_name as site_name, 
      site_section_name as site_section,
      ad_unit_name as ad_unit,
      delivery_medium_name as delivery_medium,
      screen_location_name as screen_location,
      size_name as ad_unit_size,
      content_topic_name as content_topic,
      country_name as country,
      sum(requests) as requests,
      sum(impressions) as impressions,
      sum(billable_impressions) as billable_impressions,
      sum(clicks) as clicks,
      sum(view_conversions + click_conversions) as total_conversions,
      truncate(sum(publisher_revenue + network_revenue),6) as gross_revenue,
      truncate(sum(publisher_revenue),6) as publisher_revenue,
      truncate(sum(network_revenue),6) as network_revenue,
      ifnull(truncate(((sum(publisher_revenue)*1000)/sum(billable_impressions)),6),0) as publisher_billable_eRPM,
      ifnull(truncate(((sum(publisher_revenue + network_revenue)*1000)/sum(billable_impressions)),6),0) as network_billable_eRPM,
      ifnull(truncate(((sum(publisher_revenue)*1000)/sum(impressions)),6),0) as publisher_eRPM,
      ifnull(truncate(((sum(publisher_revenue + network_revenue)*1000)/sum(impressions)),6),0) as network_eRPM,
      count(*) as grp_cnt, 
      count(guaranteed_rev) guaranteed_rev_cnt,
      sum(guaranteed_rev) guaranteed_rev
    from ( 
    select
      scd.t_sales_channel_name,
      sd.t_account_name,
      sd.account_id,
      sd.currency_code, 
      sd.site_name, 
      sd.site_section_name,
      sd.ad_unit_name,
      sd.delivery_medium_name,
      sd.screen_location_name,
      sd.size_name,
      ct.content_topic_name,
      gd.country_name,
      sf.requests,
      sf.impressions,
      sf.billable_impressions,
      sf.clicks,
      sf.view_conversions, 
      sf.click_conversions,
      (sf.publisher_revenue + sf.publisher_conversion_revenue + sf.publisher_cpd_revenue) as publisher_revenue,
      (sf.network_revenue + sf.network_conversion_revenue + sf.network_cpd_revenue) as network_revenue,
      if((sd.deal_type_uid in ('DEALTYPE.VARIABLE', 'DEALTYPE.FIXEDFALLBACK','DEALTYPE.FIXEDFILL')), ((sd.deal_cpm * sf.billable_impressions)/1000),null) as guaranteed_rev
    from sales_channel_dim scd,
       supply_dim sd,
       content_topic_group_map ctgm, 
       content_topic ct,
       geo_dim gd,
       platform_dim pd
    where sf.sales_channel_key = scd.sales_channel_key
      and sf.supply_key = sd.supply_key
      and sd.content_topic_group_key = ctgm.content_topic_group_key 
      and ctgm.content_topic_key = ct.content_topic_key 
      and gd.geo_key = sf.geo_key
      and sd.platform_id = pd.platform_id
      and $dateRange"
      ) s
    group by $goblist
    order by $goblist) t0
  inner join token t1 on (t0.t_sales_channel_name = t1.token and t1.field = 'sales_channel_name')
  inner join token t2 on (t0.t_account_name = t2.token and t2.field = 'account_name')
  $token_joins"

