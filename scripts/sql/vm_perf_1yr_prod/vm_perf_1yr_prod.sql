DROP TABLE IF EXISTS vm_metrics;

CREATE TABLE vm_metrics (
    vm      varchar(99) NOT NULL,
    metric  varchar(50) NOT NULL,
    time    datetime    NOT NULL,
    value   double      NULL,
    PRIMARY KEY (vm, metric, time)
);

-- use pathing to capstone container, since that'll be where these get loaded in from.
LOAD DATA LOCAL INFILE '/home/capstone/data/raw/vm_perf_1yr_prod Gary Varney/vm_perf_1yr_prod.csv'
INTO TABLE vm_metrics
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(vm, metric, @t, @v)
SET time  = STR_TO_DATE(@t, '%m/%d/%Y %h:%i:%s %p'),
    value = NULLIF(@v, '');

-- check after
CREATE INDEX idx_vm_metrics_metric_time ON vm_metrics (metric, time);
