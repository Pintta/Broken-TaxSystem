MySQL.ready(function()
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS verotilit (
            citizenid VARCHAR(50) PRIMARY KEY,
            total_tax_paid DOUBLE DEFAULT 0
        );
    ]])
end)