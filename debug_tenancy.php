<?php
// Debug script to check config values
$config = config('tenancy.central_domains');
$host = request()->getHost();
\Log::info('Debug Host: ' . $host);
\Log::info('Debug Central Domains: ' . json_encode($config));

if (!in_array($host, $config)) {
    \Log::error('Tenancy Error: Host not in central domains!');
    if (class_exists(\Stancl\Tenancy\Middleware\InitializeTenancyByDomain::class)) {
      \Log::info('Tenancy Middleware Active');
    }
}
