-- 1
select ItemAdd('http://cnn.com/activities/10', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 1 * INTERVAL '1 second', 'activity', 'Untouched', 'http://cnn.com/', 'http://cnn.com/', 'jskit', 0, 0, 0, 0, 0, null, null, null, null, null, null);

-- 2
select ItemAdd('http://echo.com/item/2', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 2 * INTERVAL '1 second', 'comment', 'SystemFlagged', 'http://cnn.com/', 'http://cnn.com/', 'jskit', 0, 0, 0, 0, 0, null, null, null, null, null, null);

-- 3
select ItemAdd('http://echo.com/item/32', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 3 * INTERVAL '1 second', 'comment', 'Approved', 'http://cnn.com/topics1/article1', 'http://cnn.com/topics1/article1', 'jskit', 0, 0, 0, 0, 0, null, 'John', null, null, null, 'hot');

-- 4
select ItemAdd('http://echo.com/item/1', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 4 * INTERVAL '1 second', 'comment', 'SystemFlagged', 'http://cnn.com/topics1/article1', 'http://cnn.com/topics1/article1', 'jskit', 0, 0, 0, 0, 0, null, 'John', null, null, null, null);

-- 5
select ItemAdd('http://twitter.com/456', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 5 * INTERVAL '1 second', 'comment', 'Untouched', 'http://cnn.com/topics1/article1', 'http://cnn.com/topics1/article1', 'twitter', 0, 0, 0, 0, 0, null, 'twitterUsername5', null, null, 'obama', null);

-- 5
-- select ItemAdd('http://twitter.com/456', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 5 * INTERVAL '1 second', 'comment', 'Untouched', 'http://wapo.com/g', 'http://wapo.com/g', 'twitter', 0, 0, 0, 0, 0, null, 'twitterUsername5', null, null, 'obama', null);

-- 6
select ItemAdd('http://cnn.com/ratings/2', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 6 * INTERVAL '1 second', 'rating', 'Approved', 'http://cnn.com/topics1/article1', 'http://cnn.com/topics1/article1', 'jskit', 0, 0, 0, 0, 0, null, 'John', null, null, null, null);

-- 7
select ItemAdd('http://echo.com/item/90', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 7 * INTERVAL '1 second', 'comment', 'Untouched', 'http://cnn.com/topics1/article2', 'http://cnn.com/topics1/article2', 'jskit', 0, 0, 0, 0, 0, null, 'Lala', null, null, null, 'hot');

-- 8
select ItemAdd('http://echo.com/item/36', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 8 * INTERVAL '1 second', 'comment', 'Untouched', 'http://cnn.com/topics1/article1', 'http://echo.com/item/32', 'jskit', 0, 0, 0, 0, 0, null, 'Lev', null, null, 'obama', null);

-- 9
select ItemAdd('http://echo.com/item/37', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 9 * INTERVAL '1 second', 'comment', 'SystemFlagged', 'http://cnn.com/topics1/article1', 'http://echo.com/item/32', 'jskit', 0, 0, 0, 0, 0, null, 'Chris', null, null, null, null);

-- 10
select ItemAdd('http://echo.com/item/34', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 10 * INTERVAL '1 second', 'comment', 'Deleted', 'http://cnn.com/topics1/article1', 'http://echo.com/item/34', 'jskit', 0, 0, 0, 0, 0, null, 'Mary', null, null, null, null);

-- 11
select ItemAdd('http://echo.com/item/13', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 11 * INTERVAL '1 second', 'comment', 'Approved', 'http://cnn.com/topics1/article1', 'http://echo.com/item/1', 'jskit', 0, 0, 0, 0, 0, null, 'Carl', null, null, null, 'hot');

-- 12
select ItemAdd('http://echo.com/item/100', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 12 * INTERVAL '1 second', 'comment', 'Untouched', 'http://cnn.com/topics1/article1', 'http://twitter.com/456', 'jskit', 0, 0, 0, 0, 0, null, 'John', null, null, null, null);

-- 13
select ItemAdd('http://echo.com/item/67', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 13 * INTERVAL '1 second', 'comment', 'Approved', 'http://cnn.com/topics1/article1', 'http://cnn.com/ratings/2', 'jskit', 0, 0, 0, 0, 0, null, 'Carla', null, null, null, null);

-- 14
select ItemAdd('http://echo.com/item/80', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 14 * INTERVAL '1 second', 'comment', 'Approved', 'http://cnn.com/topics1/article1', 'http://echo.com/item/36', 'jskit', 0, 0, 0, 0, 0, null, 'Vlad', null, null, null, null);

-- 15
select ItemAdd('http://twitter.com/123', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 15 * INTERVAL '1 second', 'comment', 'Approved', 'http://cnn.com/topics1/article1', 'http://echo.com/item/36', 'twitter', 0, 0, 0, 0, 0, null, 'TwitterUsername1', null, null, 'obama', 'hot');

-- 15
select ItemAdd('http://twitter.com/123', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 15 * INTERVAL '1 second', 'comment', 'Approved', 'http://cnn.com/topics1/article1', 'http://echo.com/item/37', 'twitter', 0, 0, 0, 0, 0, null, 'TwitterUsername1', null, null, 'obama', 'hot');

-- 16
select ItemAdd('http://echo.com/item/70', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 16 * INTERVAL '1 second', 'comment', 'Approved', 'http://cnn.com/topics1/article1', 'http://echo.com/item/37', 'jskit', 0, 0, 0, 0, 0, null, 'Bob', null, null, null, null);

-- 17
select ItemAdd('http://echo.com/item/120', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 17 * INTERVAL '1 second', 'comment', 'Untouched', 'http://cnn.com/topics1/article1', 'http://echo.com/item/13', 'jskit', 0, 0, 0, 0, 0, null, 'Carl', null, null, null, null);

-- 17
-- select ItemAdd('http://echo.com/item/120', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 17 * INTERVAL '1 second', 'comment', 'Untouched', 'http://wapo.com/g', 'http://wapo.com/item/232', 'jskit', 0, 0, 0, 0, 0, null, 'Carl', null, null, null, null);

-- 18
select ItemAdd('http://echo.com/item/51', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 18 * INTERVAL '1 second', 'comment', 'Untouched', 'http://cnn.com/topics1/article1', 'http://echo.com/item/13', 'jskit', 0, 0, 0, 0, 0, null, 'Carl', null, null, null, null);

-- 19
select ItemAdd('http://echo.com/item/52', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 19 * INTERVAL '1 second', 'comment', 'Untouched', 'http://cnn.com/topics1/article1', 'http://echo.com/item/13', 'jskit', 0, 0, 0, 0, 0, null, 'Carl', null, null, null, null);

-- 20
select ItemAdd('http://echo.com/item/60', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 20 * INTERVAL '1 second', 'comment', 'Untouched', 'http://cnn.com/topics1/article1', 'http://echo.com/item/13', 'jskit', 0, 0, 0, 0, 0, null, 'Carl', null, null, null, null);

-- 21
select ItemAdd('http://twitter.com/234', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 21 * INTERVAL '1 second', 'comment', 'Approved', 'http://cnn.com/topics1/article1', 'http://twitter.com/123', 'twitter', 0, 0, 0, 0, 0, null, 'TwitterUsername2', null, null, null, null);

-- 22
select ItemAdd('http://echo.com/item/200', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 22 * INTERVAL '1 second', 'comment', 'SystemFlagged', 'http://cnn.com/topics1/article1', 'http://twitter.com/123', 'jskit', 0, 0, 0, 0, 0, null, 'Sandy', null, null, null, null);

-- 23
select ItemAdd('http://echo.com/item/210', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 23 * INTERVAL '1 second', 'comment', 'Untouched', 'http://cnn.com/topics1/article1', 'http://twitter.com/123', 'jskit', 0, 0, 0, 0, 0, null, 'John', null, null, null, null);

-- 24
select ItemAdd('http://echo.com/item/250', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 24 * INTERVAL '1 second', 'comment', 'Untouched', 'http://cnn.com/topics1/article1', 'http://echo.com/item/120', 'jskit', 0, 0, 0, 0, 0, null, 'Alexander', null, null, null, null);

-- 25
select ItemAdd('http://twitter.com/271', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 25 * INTERVAL '1 second', 'comment', 'Untouched', 'GAE', 'GAE', 'twitter', 0, 0, 0, 0, 0, null, 'TwitterUsername16', null, null, 'obama', null);

-- 26
select ItemAdd('http://cnn.com/activities/34', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 26 * INTERVAL '1 second', 'activity', 'Approved', 'http://wapo.com/g', 'http://wapo.com/g', 'jskit', 0, 0, 0, 0, 0, null, 'cnn_stuff', null, null, 'obama', null);

-- 27
select ItemAdd('http://twitter.com/311', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 27 * INTERVAL '1 second', 'comment', 'Approved', 'http://wapo.com/g', 'http://wapo.com/g', 'twitter', 0, 0, 0, 0, 0, null, 'twitterUsername12', null, null, 'obama', null);

-- 5 <-> 28
select ItemAdd('http://twitter.com/456', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 28 * INTERVAL '1 second', 'comment', 'Approved', 'http://wapo.com/g', 'http://wapo.com/g', 'twitter', 0, 0, 0, 0, 0, null, 'twitterUsername5', null, null, 'obama', null);

-- 29
select ItemAdd('http://twitter.com/232', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 29 * INTERVAL '1 second', 'comment', 'Approved', 'http://wapo.com/item/45', 'http://wapo.com/item/45', 'jskit', 0, 0, 0, 0, 0, null, 'Wapo editor', null, null, null, null);

-- 30
select ItemAdd('http://dowjones.com/index/feed/item/123', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 30 * INTERVAL '1 second', 'comment', 'Approved', 'GAE', 'GAE', 'jskit', 0, 0, 0, 0, 0, null, 'dowjonesfeed', null, null, 'obama', null);

-- 31
select ItemAdd('http://echo.com/item/180', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 31 * INTERVAL '1 second', 'comment', 'Approved', 'http://wapo.com/g', 'http://twitter.com/311', 'jskit', 0, 0, 0, 0, 0, null, 'Mary', null, null, null, null);

-- 32
select ItemAdd('http://echo.com/item/100', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 32 * INTERVAL '1 second', 'comment', 'Untouched', 'http://wapo.com/g', 'http://twitter.com/456', 'jskit', 0, 0, 0, 0, 0, null, 'John', null, null, null, null);

-- 17 <-> 33
select ItemAdd('http://echo.com/item/120', TIMESTAMP WITHOUT TIME ZONE 'epoch' + 17 * INTERVAL '1 second', 'comment', 'Approved', 'http://wapo.com/item/45', 'http://wapo.com/item/232', 'jskit', 0, 0, 0, 0, 0, null, 'Bob', null, null, null, null);

