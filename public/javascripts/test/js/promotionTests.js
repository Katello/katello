//Required data objects for testing
var changeset_breadcrumb = $.parseJSON('{\"product-cs_3_1\":{\"name\":\"TestProduct\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\",\"changeset_3\"]},\"changeset_4\":{\"is_new\":true,\"name\":\"EricNoise\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\"]},\"changeset_5\":{\"is_new\":true,\"name\":\"TestThisAgbain\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\"]},\"repo-cs_5_1\":{\"name\":\"Repositories\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\",\"changeset_5\",\"product-cs_5_1\"]},\"errata-cs_12_1\":{\"name\":\"Errata\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\",\"changeset_12\",\"product-cs_12_1\"]},\"product-cs_5_1\":{\"name\":\"TestProduct\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\",\"changeset_5\"]},\"changeset_6\":{\"is_new\":true,\"name\":\"NewTestChange\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\"]},\"package-cs_8_1\":{\"name\":\"Packages\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\",\"changeset_8\",\"product-cs_8_1\"]},\"errata-cs_8_1\":{\"name\":\"Errata\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\",\"changeset_8\",\"product-cs_8_1\"]},\"errata-cs_13_1\":{\"name\":\"Errata\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\",\"changeset_13\",\"product-cs_13_1\"]},\"changeset_8\":{\"is_new\":true,\"name\":\"TestNewAdd\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\"]},\"repo-cs_8_1\":{\"name\":\"Repositories\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\",\"changeset_8\",\"product-cs_8_1\"]},\"changesets\":{\"name\":\"Changesets\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[]},\"product-cs_8_1\":{\"name\":\"TestProduct\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\",\"changeset_8\"]},\"changeset_10\":{\"is_new\":true,\"name\":\"BrandNew\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\"]},\"package-cs_10_1\":{\"name\":\"Packages\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\",\"changeset_10\",\"product-cs_10_1\"]},\"repo-cs_10_1\":{\"name\":\"Repositories\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\",\"changeset_10\",\"product-cs_10_1\"]},\"product-cs_10_1\":{\"name\":\"TestProduct\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\",\"changeset_10\"]},\"changeset_11\":{\"is_new\":true,\"name\":\"EmptyChangeset\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\"]},\"package-cs_3_1\":{\"name\":\"Packages\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\",\"changeset_3\",\"product-cs_3_1\"]},\"changeset_12\":{\"is_new\":false,\"name\":\"TestYuou\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\"]},\"package-cs_12_1\":{\"name\":\"Packages\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\",\"changeset_12\",\"product-cs_12_1\"]},\"repo-cs_12_1\":{\"name\":\"Repositories\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\",\"changeset_12\",\"product-cs_12_1\"]},\"errata-cs_3_1\":{\"name\":\"Errata\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\",\"changeset_3\",\"product-cs_3_1\"]},\"product-cs_12_1\":{\"name\":\"TestProduct\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\",\"changeset_12\"]},\"changeset_13\":{\"is_new\":true,\"name\":\"New Test\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\"]},\"package-cs_13_1\":{\"name\":\"Packages\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\",\"changeset_13\",\"product-cs_13_1\"]},\"repo-cs_13_1\":{\"name\":\"Repositories\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\",\"changeset_13\",\"product-cs_13_1\"]},\"package-cs_5_1\":{\"name\":\"Packages\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\",\"changeset_5\",\"product-cs_5_1\"]},\"product-cs_13_1\":{\"name\":\"TestProduct\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\",\"changeset_13\"]},\"changeset_14\":{\"is_new\":true,\"name\":\"Thisismynewhchangeset\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\"]},\"changeset_3\":{\"is_new\":true,\"name\":\"XXX\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\"]},\"repo-cs_3_1\":{\"name\":\"Repositories\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\",\"changeset_3\",\"product-cs_3_1\"]},\"errata-cs_5_1\":{\"name\":\"Errata\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\",\"changeset_5\",\"product-cs_5_1\"]},\"errata-cs_10_1\":{\"name\":\"Errata\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\",\"changeset_10\",\"product-cs_10_1\"]},\"changeset_15\":{\"is_new\":true,\"name\":\"TestThis\",\"client_render\":true,\"cache\":null,\"url\":\"\",\"trail\":[\"changesets\"]}}');
var content_breadcrumb = $.parseJSON('{\"packages_1\":{\"name\":\"Packages\",\"cache\":null,\"url\":\"/organizations/ACME_Corporation/environments/locker/promotions/packages?changeset_id=1&product_id=1\",\"trail\":[\"content\",\"products\",\"details_1\"],\"scrollable\":true},\"details_1\":{\"name\":\"TestProduct\",\"cache\":true,\"url\":\"/organizations/ACME_Corporation/environments/locker/promotions/detail?product_id=1\",\"content\":\"<ul>\\n  <li>\\n    <div class=\'slide_link\' id=\'packages_1\'>\\n      <span>Packages<\/span>\\n    <\/div>\\n  <\/li>\\n  <li>\\n    <div class=\'slide_link\' id=\'errata_1\'>\\n      <span>Errata<\/span>\\n    <\/div>\\n  <\/li>\\n  <li>\\n    <div class=\'slide_link\' id=\'repo_1\'>\\n      <span>Repositories<\/span>\\n    <\/div>\\n  <\/li>\\n<\/ul>\\n\",\"trail\":[\"content\",\"products\"]},\"repo_1\":{\"name\":\"Repos\",\"cache\":null,\"url\":\"/organizations/ACME_Corporation/environments/locker/promotions/repos?changeset_id=1&product_id=1\",\"trail\":[\"content\",\"products\",\"details_1\"],\"scrollable\":true},\"products\":{\"name\":\"Products\",\"cache\":true,\"url\":\"/organizations/ACME_Corporation/environments/locker/promotions/products\",\"content\":\"<ul class=\'expand_list\'>\\n  <li class=\'clear\'>\\n    <a class=\'content_add_remove add_product st_button fr\' data-display_name=\'TestProduct\' data-id=\'1\' data-product_id=\'1\' data-type=\'product\' id=\'add_remove_product_1\'>\\n      + Add\\n    <\/a>\\n    <div class=\'slide_link\' id=\'details_1\'>\\n      <span class=\'custom-product-sprite\'><\/span>\\n      <span class=\'product-icon\' style=\'display: inline;\'>\\n        TestProduct&nbsp;\\n        <div class=\'product_arch\'>\\n          noarch\\n        <\/div>\\n      <\/span>\\n    <\/div>\\n  <\/li>\\n<\/ul>\\n<br class=\'clear\'>\\n\",\"trail\":[\"content\"]},\"content\":{\"name\":\"Content\",\"cache\":true,\"url\":\"/organizations/ACME_Corporation/environments/locker/promotions/detail\",\"content\":\"<ul>\\n  <li>\\n    <div class=\'slide_link\' id=\'products\'>\\n      <span>Products<\/span>\\n    <\/div>\\n  <\/li>\\n  <li>\\n    <div class=\'slide_link\' id=\'all_errata\'>\\n      <span>All Errata<\/span>\\n    <\/div>\\n  <\/li>\\n<\/ul>\\n\",\"trail\":[]},\"errata_1\":{\"name\":\"Errata\",\"cache\":null,\"url\":\"/organizations/ACME_Corporation/environments/locker/promotions/errata?changeset_id=1&product_id=1\",\"trail\":[\"content\",\"products\",\"details_1\"],\"scrollable\":true},\"all_errata\":{\"name\":\"All Errata\",\"cache\":null,\"url\":\"/organizations/ACME_Corporation/environments/locker/promotions/errata\",\"trail\":[\"content\"],\"scrollable\":true}}');

var changeset_data_struct = {
    "is_new":true, 
    "timestamp":"1309529326",
    "id":"6",
    "products": {
        "1": {
            "name":"TestProduct",
            "repo":[],
            "errata":[],
            "id":1,
            "package": [{"name":"NOCpulsePlugins-2.209.1-1.fc12.noarch", "id":"c155f38b-d276-4539-8613-3a0530ff49ae"},
                        {"name":"SatConfig-bootstrap-1.11.5-1.fc12.noarch","id":"8df7cc62-3b94-407f-a023-0ec210879236"},
                        {"name":"SNMPAlerts-0.5.5-1.fc12.noarch","id":"7440d8bc-b98a-46ca-963f-7717b14f7465"},
                        {"name":"SatConfig-dbsynch-1.3.2-1.fc12.noarch","id":"527b7d86-bc2e-47c8-9acd-a61277ebb490"},
                        {"name":"SatConfig-generator-2.29.12-1.fc12.noarch","id":"7514ebc2-8ccf-4fd2-b9fe-e3efbddbaab2"},
                        {"name":"SatConfig-general-1.216.19-1.fc12.noarch","id":"a0c3c62a-1af2-41d0-a9fd-b5301c597fa7"},
                        {"name":"cx_Oracle-4.4.1-1.fc12.x86_64","id":"b83fa208-0d1e-444c-aec1-c693e8c54d7e"},
                        {"name":"c3p0-javadoc-0.9.0-2jpp.ep1.1.fc12.noarch","id":"a9845fea-3b58-4ebe-aec5-3cd0aefc36af"}],
            "provider":"Custom"},
        "2":{ 
            "name":"MoonWalk",
            "repo":[],
            "all":true,
            "errata":[],
            "id":2,
            "package":[],
            "provider":"Custom"}}
};


module('Changeset Object CRUD');
test('Changeset Object Creation', function(){
    ok(changeset_obj(changeset_data_struct), 'Should create changeset object.');
});

module('Changeset Object Properties', {
    setup: function(){
        this.changeset = changeset_obj(changeset_data_struct);     
    }
});
test('id', function(){
   strictEqual(this.changeset.id, "6", 'true')
});
test('products', function(){
   strictEqual(this.changeset.products, changeset_data_struct.products, 'true')
});
test('timestamp', function(){
   strictEqual(this.changeset.timestamp(), changeset_data_struct.timestamp, 'true')
});
test('is_new', function(){
   strictEqual(this.changeset.is_new(), changeset_data_struct.is_new, 'true')
});
test('Product Count', function(){
   equals(this.changeset.productCount(), 2, 'true'); 
});
test('Set timestamp', function(){
    var ts = 345768696;
    this.changeset.set_timestamp(ts); 
    equals(this.changeset.timestamp(), ts, 'true'); 
});
test('Should have package 7440d8bc-b98a-46ca-963f-7717b14f7465', function(){ 
    ok(this.changeset.has_item('package', "7440d8bc-b98a-46ca-963f-7717b14f7465", "1"), 'true'); 
});
test('Should have package SNMPAlerts-0.5.5-1.fc12.noarch', function(){ 
    ok(this.changeset.has_item('package', "7440d8bc-b98a-46ca-963f-7717b14f7465", "1"), 'true'); 
});
test('Should not have package eventReceivers-2.20.15-1.fc12.noarch', function(){
    equals(this.changeset.has_item('package', "479900a7-a077-46bc-bfc9-5baafbb30e82", "1"), false, 'true'); 
});
test('Should add package eventReceivers-2.20.15-1.fc12.noarch', function(){
    equals(this.changeset.has_item('package', "479900a7-a077-46bc-bfc9-5baafbb30e82", "1"), false, 'true'); 
});