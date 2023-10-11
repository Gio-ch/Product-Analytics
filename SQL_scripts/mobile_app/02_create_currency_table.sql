-- Create and Populate Currency Conversion Table
CREATE TABLE IF NOT EXISTS GameAnalyticsDB.currency_conversion (
    currency_code VARCHAR(3) PRIMARY KEY,
    to_eur_rate FLOAT
);

DELETE FROM GameAnalyticsDB.currency_conversion;  

INSERT INTO GameAnalyticsDB.currency_conversion (currency_code, to_eur_rate)
VALUES 
('EUR', 1),
('USD', 0.85),
('GBP', 1.17),
('JPY', 0.0075);

select * 
from GameAnalyticsDB.currency_conversion;