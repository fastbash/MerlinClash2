<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<html xmlns:v>
<head>
	<meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta HTTP-EQUIV="Pragma" CONTENT="no-cache">
	<meta HTTP-EQUIV="Expires" CONTENT="-1">
	<link rel="shortcut icon" href="images/favicon.png">
	<link rel="icon" href="images/favicon.png">
	<title>【Merlin Clash 2】</title>
	<link rel="stylesheet" type="text/css" href="index_style.css">
	<link rel="stylesheet" type="text/css" href="form_style.css">
	<link rel="stylesheet" type="text/css" href="usp_style.css">
	<link rel="stylesheet" type="text/css" href="css/element.css">
	<link rel="stylesheet" type="text/css" href="/device-map/device-map.css">
	<link rel="stylesheet" type="text/css" href="/js/table/table.css">
	<link rel="stylesheet" type="text/css" href="/res/layer/theme/default/layer.css">
	<link rel="stylesheet" type="text/css" href="/res/softcenter.css">
	<link rel="stylesheet" type="text/css" href="/res/merlinclash.css">
	<script language="JavaScript" type="text/javascript" src="/js/jquery.js"></script>
	<script language="JavaScript" type="text/javascript" src="/res/layer/layer.js"></script>
	<script language="JavaScript" type="text/javascript" src="/js/httpApi.js"></script>
	<script language="JavaScript" type="text/javascript" src="/state.js"></script>
	<script language="JavaScript" type="text/javascript" src="/general.js"></script>
	<script language="JavaScript" type="text/javascript" src="/popup.js"></script>
	<script language="JavaScript" type="text/javascript" src="/help.js"></script>
	<script language="JavaScript" type="text/javascript" src="/validator.js"></script>
	<script language="JavaScript" type="text/javascript" src="/client_function.js"></script>
	<script language="JavaScript" type="text/javascript" src="/js/table/table.js"></script>
	<script language="JavaScript" type="text/javascript" src="/res/mc-menu.js"></script>
	<script language="JavaScript" type="text/javascript" src="/res/softcenter.js"></script>
	<script>
		var db_merlinclash={};
		var db_merlinclash_tmp={};
		var _responseLen;
		var x = 5;
		var noChange = 0;
		var node_max = 0;
		var acl_node_max = 0;
		var kpacl_node_max = 0;
		// var devices_node_max = 0;
		// var whitelists_node_max = 0;
		// var kcp_node_max = 0;
		// var kpyacl_node_max = 0;
		// var rule_node_max = 0;
		// var ipports_node_max = 0;
		var nokpacl_node_max = 0;
		// var unmacl_node_max = 0;
		// var edit_falg;
		var log_count = 0;
		var select_count = 0;
		var dy_count = 0;
		var yamlview_count = 0;
		var init_count = 0;
		// var init_kpcount = 0;
		// var init_kpcount2 = 0;
		var init_hostcount = 0;
		var init_nokpaclcount = 0;
		var init_aclcount = 0;
		var init_advancedcount = 0;
		var init_unblockcount = 0;
		var init_circount = 0;
		var init_sniffercount = 0;
		var init_cusrulecount = 0;
		var requestList = [];
        var queue_switch = true;//默认进队列
function init() {
    	show_menu(menu_hook);
			//初始化获取Dbus值
			get_dbus_data();
			//处理请求
			doRequest();
}

/**
 * 队列处理请求，防止并发请求过多
 * @returns {Promise<void>}
 */
 async function doRequest(){
 	let i = 0;
 	let isRequest = false;
 	for (i = 0;i < requestList.length;i++) {
 		let ajaxConfig = requestList[i];

 		if( 
    		(! ajaxConfig.data || typeof ajaxConfig.data !== 'string' || ! ajaxConfig.data.includes('clash_status'))//请求数据不包含 clash_status
    		&& ! ajaxConfig.url.includes('log') //请求地址不包含log
    	){//显示遮罩层
 			$("#loadingMask").show();
 	}
    	// console.log('开始请求',ajaxConfig.url,ajaxConfig.data);

    	try{
    		await $.ajax(ajaxConfig);
    	}catch(e){
    		console.log('捕获到异常啦',e)
    	}
        //移出队列
        requestList.splice(i, 1);
        isRequest = true;
    }

    if(isRequest){
    	console.log('请求队列处理完了~');
    	$("#loadingMask").hide();
    }

    setTimeout('doRequest();',50);//写入定时器
}

/**
 * 进入队列
 */
 function intoQueue(ajaxConfig) {
    //只有请求路由器的才队列
    if(ajaxConfig.url.startsWith('/')){
    	if (queue_switch){
    		requestList.push(ajaxConfig)
    	}else{
    		$.ajax(ajaxConfig);
    	}
    }else{
    	$.ajax(ajaxConfig);
    }
}

function get_dbus_data() {
	$.ajax({
		type: "GET",
		url: "/_api/merlinclash",
		async: false,
		success: function(data) {
   			//初始化DBUS数据
   			db_merlinclash = data.result[0];

			/**
			 * 处理获取数据库之后的逻辑
			 */
			//定时作业下拉数据
			load_cron_params();

			//开始处理数据
			E("merlinclash_enable").checked = db_merlinclash["merlinclash_enable"] == "1";
			E("merlinclash_watchdog").checked = db_merlinclash["merlinclash_watchdog"] == "1";
			if(db_merlinclash["merlinclash_linuxver"] >= 41){
				E("merlinclash_ipv6switch").checked = db_merlinclash["merlinclash_ipv6switch"] == "1";
			}
			E("merlinclash_cirswitch").checked = db_merlinclash["merlinclash_cirswitch"] == "1";
			E("merlinclash_startlog").checked = db_merlinclash["merlinclash_startlog"] == "1";
			if(db_merlinclash["merlinclash_queue_switch"] === undefined){
				E("merlinclash_queue_switch").checked = true;
			}else{
				queue_switch = db_merlinclash["merlinclash_queue_switch"] == "1";
				E("merlinclash_queue_switch").checked = db_merlinclash["merlinclash_queue_switch"] == "1";
			}
			// E("merlinclash_open_kernel_tfo").checked = merlinclash_open_kernel_tfo == "1";
			E("merlinclash_recordbycron").checked = db_merlinclash["merlinclash_recordbycron"] == "1";
			E("merlinclash_dnsgoclash").checked = db_merlinclash["merlinclash_dnsgoclash"] == "1";
			E("merlinclash_dnsclear").checked = db_merlinclash["merlinclash_dnsclear"] == "1";
			E("merlinclash_mixport_enable").checked = db_merlinclash["merlinclash_mixport_enable"] == "1";
			E("merlinclash_sniffer").checked = db_merlinclash["merlinclash_sniffer"] == "1";
			E("merlinclash_tcp_concurrent").checked = db_merlinclash["merlinclash_tcp_concurrent"] == "1";
			E("merlinclash_closeproxy").checked = db_merlinclash["merlinclash_closeproxy"] == "1";
			E("merlinclash_dashboardswitch").checked = db_merlinclash["merlinclash_dashboardswitch"] == "1";
			E("merlinclash_check_dlercloud").checked = db_merlinclash["merlinclash_check_dlercloud"] == "1";
			E("merlinclash_check_aclrule").checked = db_merlinclash["merlinclash_check_aclrule"] == "1";
			E("merlinclash_check_controllist").checked = db_merlinclash["merlinclash_check_controllist"] == "1";
			E("merlinclash_check_cdns").checked = db_merlinclash["merlinclash_check_cdns"] == "1";
			E("merlinclash_check_ipsetproxy").checked = db_merlinclash["merlinclash_check_ipsetproxy"] == "1";
			E("merlinclash_check_ipsetproxyarround").checked = db_merlinclash["merlinclash_check_ipsetproxyarround"] == "1";
			E("merlinclash_check_chost").checked = db_merlinclash["merlinclash_check_chost"] == "1";
			E("merlinclash_check_cusport").checked = db_merlinclash["merlinclash_check_cusport"] == "1";
			E("merlinclash_check_clashimport").checked = db_merlinclash["merlinclash_check_clashimport"] == "1";
			E("merlinclash_check_sclocal").checked = db_merlinclash["merlinclash_check_sclocal"] == "1";
			E("merlinclash_check_yamldown").checked = db_merlinclash["merlinclash_check_yamldown"] == "1";
			E("merlinclash_check_noipt").checked = db_merlinclash["merlinclash_check_noipt"] == "1";
			E("merlinclash_check_tproxy").checked = db_merlinclash["merlinclash_check_tproxy"] == "1";
			E("merlinclash_check_delay_cbox").checked = db_merlinclash["merlinclash_check_delay_cbox"] == "1";
			E("merlinclash_auto_delay_cbox").checked = db_merlinclash["merlinclash_auto_delay_cbox"] == "1";
			E("merlinclash_customrule_cbox").checked = db_merlinclash["merlinclash_customrule_cbox"] == "1";
			E("merlinclash_custom_cbox").checked = db_merlinclash["merlinclash_custom_cbox"] == "1";
			E("merlinclash_urltestTolerance_cbox").checked = db_merlinclash["merlinclash_urltestTolerance_cbox"] == "1";
			E("merlinclash_interval_cbox").checked = db_merlinclash["merlinclash_interval_cbox"] == "1";
			if(db_merlinclash["merlinclash_dns_fakeipblack"]){
				E("merlinclash_dns_fakeipblack").value = db_merlinclash["merlinclash_dns_fakeipblack"];
			}
			if(db_merlinclash["merlinclash_urltestTolerancesel"]){
				E("merlinclash_urltestTolerancesel").value = db_merlinclash["merlinclash_urltestTolerancesel"];
			}
			if(db_merlinclash["merlinclash_intervalsel"]){
				E("merlinclash_intervalsel").value = db_merlinclash["merlinclash_intervalsel"];
			}
			//20200828-
			if(db_merlinclash["merlinclash_nokpacl_method"]){
				E("merlinclash_nokpacl_method").value = db_merlinclash["merlinclash_nokpacl_method"];
			}
			if(db_merlinclash["merlinclash_links"]){
				E("merlinclash_links").value = Base64.decode(db_merlinclash["merlinclash_links"]);
			}
			if(db_merlinclash["merlinclash_links3"]){
				var delinks2 = decodeURIComponent(Base64.decode(db_merlinclash["merlinclash_links3"]));
				E("merlinclash_links3").value = delinks2;
			}
			//20210916+
			if(db_merlinclash["merlinclash_uploadiniurl"]){
				var deurl = decodeURIComponent(Base64.decode(db_merlinclash["merlinclash_uploadiniurl"]));
				E("merlinclash_uploadiniurl").value = deurl;
			}
			if(db_merlinclash["merlinclash_dc_uploadiniurl"]){
				var dcdeurl = decodeURIComponent(Base64.decode(db_merlinclash["merlinclash_dc_uploadiniurl"]));
				E("merlinclash_dc_uploadiniurl").value = dcdeurl;
			}
			//20210916-
			if(db_merlinclash["merlinclash_dnsplan"]){
				$("input:radio[name='dnsplan'][value="+db_merlinclash["merlinclash_dnsplan"]+"]").attr('checked','true');
			}
			if(db_merlinclash["merlinclash_subscribeplan"]){
				$("input:radio[name='subscribeplan'][value="+db_merlinclash["merlinclash_subscribeplan"]+"]").attr('checked','true');
			}
			if(db_merlinclash["merlinclash_dnshijack"]){
				$("input:radio[name='dnshijack'][value="+db_merlinclash["merlinclash_dnshijack"]+"]").attr('checked','true');
			}
			if(db_merlinclash["merlinclash_clashmode"]){
				$("input:radio[name='clashmode'][value="+db_merlinclash["merlinclash_clashmode"]+"]").attr('checked','true');

			}
			if(db_merlinclash["merlinclash_cusrule_plan"]){
				$("input:radio[name='cusruleplan'][value="+db_merlinclash["merlinclash_cusrule_plan"]+"]").attr('checked','true');

			}
			if(db_merlinclash["merlinclash_dnsedit_tag"]){
				$("input:radio[name='dnsplan_edit'][value="+db_merlinclash["merlinclash_dnsedit_tag"]+"]").attr('checked','true');
			}
			if(db_merlinclash["merlinclash_linuxver"] >= 41){
				if(db_merlinclash["merlinclash_tproxymode"]){
					$("input:radio[name='tproxymode'][value="+db_merlinclash["merlinclash_tproxymode"]+"]").attr('checked','true');
				}
			}
			if(db_merlinclash["merlinclash_dashboard_secret"]){
				E("merlinclash_dashboard_secret").value = db_merlinclash["merlinclash_dashboard_secret"];
			}
			if(db_merlinclash["merlinclash_useragent"]){
				var uacode = Base64.decode(db_merlinclash["merlinclash_useragent"]);
				E("merlinclash_useragent").value = uacode;
			}
			if(db_merlinclash["merlinclash_check_delay_time"]){
				E("merlinclash_check_delay_time").value = db_merlinclash["merlinclash_check_delay_time"];
			}
			if(db_merlinclash["merlinclash_cus_routingmark"]){
				E("merlinclash_cus_routingmark").value = db_merlinclash["merlinclash_cus_routingmark"];
			}
			if(db_merlinclash["merlinclash_cus_port"]){
				E("merlinclash_cus_port").value = db_merlinclash["merlinclash_cus_port"];
			}
			if(db_merlinclash["merlinclash_cus_socksport"]){
				E("merlinclash_cus_socksport").value = db_merlinclash["merlinclash_cus_socksport"];
			}
			if(db_merlinclash["merlinclash_cus_redirsport"]){
				E("merlinclash_cus_redirsport").value = db_merlinclash["merlinclash_cus_redirsport"];
			}
			if(db_merlinclash["merlinclash_cus_tproxyport"]){
				E("merlinclash_cus_tproxyport").value = db_merlinclash["merlinclash_cus_tproxyport"];
			}
			if(db_merlinclash["merlinclash_cus_dnslistenport"]){
				E("merlinclash_cus_dnslistenport").value = db_merlinclash["merlinclash_cus_dnslistenport"];
			}
			if(db_merlinclash["merlinclash_cus_dashboardport"]){
				E("merlinclash_cus_dashboardport").value = db_merlinclash["merlinclash_cus_dashboardport"];
			}
			if(db_merlinclash["merlinclash_auto_delay_time"]){
				E("merlinclash_auto_delay_time").value = db_merlinclash["merlinclash_auto_delay_time"];
			}
			if(db_merlinclash["merlinclash_watchdog_delay_time"]){
				E("merlinclash_watchdog_delay_time").value = db_merlinclash["merlinclash_watchdog_delay_time"];
			}
			if(db_merlinclash["merlinclash_dc_name"]){
				E("merlinclash_dc_name").value = decodeURIComponent(Base64.decode(db_merlinclash["merlinclash_dc_name"]));
			}
			if(db_merlinclash["merlinclash_dc_passwd"]){
				E("merlinclash_dc_passwd").value = decodeURIComponent(Base64.decode(db_merlinclash["merlinclash_dc_passwd"]));
			}
			if(db_merlinclash["merlinclash_linuxver"] < 41){
				document.getElementById("tproxy").style.display="none"
				document.getElementById("tproxy_show").style.display="none"
				document.getElementById("tproxy_showcbox").style.display="none"
				document.getElementById("subc_show").style.display="none"
			}else{
				document.getElementById("tproxy").style.display=""
				document.getElementById("tproxy_show").style.display=""
				document.getElementById("tproxy_showcbox").style.display=""
				document.getElementById("subc_show").style.display=""
			}
			if(db_merlinclash["merlinclash_check_dlercloud"] == "1"){
				document.getElementById("show_btn10").style.display=""
			}else{
				document.getElementById("show_btn10").style.display="none"
			}
			if(db_merlinclash["merlinclash_mixport_enable"] == "1"){
				document.getElementById("ip_state").style.display=""
			}else{
				document.getElementById("ip_state").style.display="none"
			}
				document.getElementById("showmsg6").style.display=""
				document.getElementById("showmsg7").style.display=""
				document.getElementById("showmsg8").style.display=""
				document.getElementById("showmsg9").style.display=""
				document.getElementById("showmsg10").style.display=""
			if(db_merlinclash["merlinclash_dnsgoclash"] == "1"){
				document.getElementById("mark_value").style.display=""
			}else{
				document.getElementById("mark_value").style.display="none"
			}
			if(db_merlinclash["merlinclash_dnsplan"]=="fi"){
				document.getElementById("dns_fakeipblack").style.display=""
			}else{
				document.getElementById("dns_fakeipblack").style.display="none"
			}

			if(db_merlinclash["merlinclash_check_aclrule"] == "1"){
				document.getElementById("show_btn2").style.display=""
			}else{
				document.getElementById("show_btn2").style.display="none"
			}document.getElementById("show_btn88").style.display="none"
			if(db_merlinclash["merlinclash_check_controllist"] == "1"){
				document.getElementById("show_btn9").style.display=""
			}else{
				document.getElementById("show_btn9").style.display="none"
			}
			if(db_merlinclash["merlinclash_check_cdns"] == "1"){
				document.getElementById("clash_dns_area").style.display=""
			}else{
				document.getElementById("clash_dns_area").style.display="none"
			}
			if(db_merlinclash["merlinclash_check_ipsetproxy"] == "1"){
				document.getElementById("clash_ipsetproxy_area").style.display=""
			}else{
				document.getElementById("clash_ipsetproxy_area").style.display="none"
			}
			if(db_merlinclash["merlinclash_check_ipsetproxyarround"] == "1"){
				document.getElementById("clash_ipsetproxyarround_area").style.display=""
			}else{
				document.getElementById("clash_ipsetproxyarround_area").style.display="none"
			}
			if(db_merlinclash["merlinclash_check_chost"] == "1"){
				document.getElementById("clash_host_area").style.display=""
			}else{
				document.getElementById("clash_host_area").style.display="none"
			}
			if(db_merlinclash["merlinclash_check_cusport"] == "1"){
				document.getElementById("clash_cusport_area").style.display=""
			}else{
				document.getElementById("clash_cusport_area").style.display="none"
			}
			if(db_merlinclash["merlinclash_check_clashimport"] == "1"){
				document.getElementById("clashimport").style.display=""
			}else{
				document.getElementById("clashimport").style.display="none"
			}
			if(db_merlinclash["merlinclash_check_sclocal"] == "1"){
				document.getElementById("subconverterlocal").style.display=""
			}else{
				document.getElementById("subconverterlocal").style.display="none"
			}
			if(db_merlinclash["merlinclash_check_yamldown"] == "1"){
				document.getElementById("clashyamldown").style.display=""
			}else{
				document.getElementById("clashyamldown").style.display="none"
			}
			if(db_merlinclash["merlinclash_check_noipt"] == "1"){
				document.getElementById("noipt").style.display=""
			}else{
				document.getElementById("noipt").style.display="none"
			}
			if(db_merlinclash["merlinclash_check_tproxy"] == "1"){
				document.getElementById("tproxy").style.display=""
			}else{
				document.getElementById("tproxy").style.display="none"
			}
			document.getElementById("up_scrule").style.display=""
			//-----------------------------------------定时订阅--------------------------------------//
			var srs=db_merlinclash["merlinclash_select_regular_subscribe"];
			$("#merlinclash_select_regular_subscribe").find("option[value ='"+srs+"']").attr("selected","selected");

			var srd=db_merlinclash["merlinclash_select_regular_day"];
			$("#merlinclash_select_regular_day").find("option[value ='"+srd+"']").attr("selected","selected");

			var srw=db_merlinclash["merlinclash_select_regular_week"];
			$("#merlinclash_select_regular_week").find("option[value ='"+srw+"']").attr("selected","selected");

			var srh=db_merlinclash["merlinclash_select_regular_hour"];
			$("#merlinclash_select_regular_hour").find("option[value ='"+srh+"']").attr("selected","selected");

			var srm=db_merlinclash["merlinclash_select_regular_minute"];
			$("#merlinclash_select_regular_minute").find("option[value ='"+srm+"']").attr("selected","selected");

			var srm2=db_merlinclash["merlinclash_select_regular_minute_2"];
			$("#merlinclash_select_regular_minute_2").find("option[value ='"+srm2+"']").attr("selected","selected");
			//-----------------------------------------定时重启--------------------------------------//
			var scr=db_merlinclash["merlinclash_select_clash_restart"];
			$("#merlinclash_select_clash_restart").find("option[value ='"+scr+"']").attr("selected","selected");

			var scrd=db_merlinclash["merlinclash_select_clash_restart_day"];
			$("#merlinclash_select_clash_restart_day").find("option[value ='"+scrd+"']").attr("selected","selected");

			var scrw=db_merlinclash["merlinclash_select_clash_restart_week"];
			$("#merlinclash_select_clash_restart_week").find("option[value ='"+scrw+"']").attr("selected","selected");

			var scrh=db_merlinclash["merlinclash_select_clash_restart_hour"];
			$("#merlinclash_select_clash_restart_hour").find("option[value ='"+scrh+"']").attr("selected","selected");

			var scrm=db_merlinclash["merlinclash_select_clash_restart_minute"];
			$("#merlinclash_select_clash_restart_minute").find("option[value ='"+scrm+"']").attr("selected","selected");

			var scrm2=db_merlinclash["merlinclash_select_clash_restart_minute_2"];
			$("#merlinclash_select_clash_restart_minute_2").find("option[value ='"+scrm2+"']").attr("selected","selected");

			//GEOIP选项
			var geo=db_merlinclash["merlinclash_geoip_type"];
			$("#merlinclash_geoip_type").find("option[value ='"+geo+"']").attr("selected","selected");

			$.each(db_merlinclash,(k,v)=>{
				db_merlinclash_tmp[k] = v;
			});

			if(E("merlinclash_enable").checked){
				merlinclash.checkIP();
			}
			/**
			 * 处理初始化结束后的数据
			 */
			//定时作业下拉切换显示
			show_job();
			//版本检查
			version_show();
			//栏目点击切换
			toggle_func();
			//下拉框获取配置文件名
			yaml_select();
			//host编辑区
			host_select();
			//获取相关状态
			get_clash_status_front();
			//DC用户初始刷新
			dc_init();
			notice_show();

		}
	});
}

var yamlsel_tmp2;
function selectlist_rebuild() {
	db_merlinclash["merlinclash_action"] = 34;
	push_data("clash_rebuild.sh", "rebuild",  db_merlinclash);
}
function quickly_restart() {
	if(!$.trim($('#merlinclash_yamlsel').val())){
		alert("必须选择一个配置文件！");
		return false;
	}
	yamlsel_tmp1 = E("merlinclash_yamlsel").value;
	var act;
	db_merlinclash["merlinclash_action"] = "1";
	push_data("clash_config.sh", "quicklyrestart",  db_merlinclash);
}
function hot_off_mc(){
	db_merlinclash["merlinclash_action"] = 42;
	push_data("clash_rebuild.sh", "hot_off_mc",  db_merlinclash);
}
function cool_off_mc(){
	layer.confirm('<li>路由器即将重启，你确定要冷关闭吗？</li>', {
		shade: 0.8,
	}, function(index) {
		$("#log_content3").attr("rows", "20");
		db_merlinclash["merlinclash_action"] = 42;
		push_data("clash_rebuild.sh", "cool_off_mc", db_merlinclash);
		layer.close(index);
		return true;

	}, function(index) {
		layer.close(index);
		return false;
	});
}
function apply() {

	if(!$.trim($('#merlinclash_dns_fakeipblack').val())){
		alert("黑名单设备DNS服务器不能为空！");
		return false;
	}
	if(!$.trim($('#merlinclash_yamlsel').val())){
		alert("必须选择一个配置文件！");
		return false;
	}
	if(!$.trim($('#merlinclash_watchdog_delay_time').val())){
		alert("看门狗检查间隔时间不能为空！");
		return false;
	}
	var host_content = E("merlinclash_host_content1").value;
	// var script_content = E("merlinclash_script_edit_content1").value;
	if(host_content != ""){
		if(host_content.search(/^hosts:/) >= 0){

		}else{
			alert("读取host区域内容有误，网页服务可能已崩溃，F5刷新页面重试");
			return false;
		}
	}
	if(!$.trim($('#merlinclash_hostsel').val())){
		alert("HOST文件选项值丢失！请刷新页面检查！！！");
		return false;
	}else{
		db_merlinclash["merlinclash_hostsel"] = E("merlinclash_hostsel").value;
		db_merlinclash["merlinclash_hostsel_tmp"] = (E("merlinclash_hostsel").value);
	}

	var radio = document.getElementsByName("dnsplan").innerHTML = getradioval(1);
	var clashmodesel = document.getElementsByName("clashmode").innerHTML = getradioval(3);
	var cusrulesel = document.getElementsByName("cusruleplan").innerHTML = getradioval(8);

	if(db_merlinclash["merlinclash_linuxver"] >= 41){
		var tproxymodesel = document.getElementsByName("tproxymode").innerHTML = getradioval(4);
	}
	var unplan = document.getElementsByName("unblockplan").innerHTML = getradioval(6);
	var dnshijacksel = document.getElementsByName("dnshijack").innerHTML = getradioval(7);
	db_merlinclash["merlinclash_enable"] = E("merlinclash_enable").checked ? '1' : '0';
	db_merlinclash["merlinclash_watchdog"] = E("merlinclash_watchdog").checked ? '1' : '0';
	if(db_merlinclash["merlinclash_linuxver"] >= 41){
		db_merlinclash["merlinclash_ipv6switch"] = E("merlinclash_ipv6switch").checked ? '1' : '0';
	}
	db_merlinclash["merlinclash_cirswitch"] = E("merlinclash_cirswitch").checked ? '1' : '0';
	db_merlinclash["merlinclash_startlog"] = E("merlinclash_startlog").checked ? '1' : '0'; //启动简化日志
	db_merlinclash["merlinclash_recordbycron"] = E("merlinclash_recordbycron").checked ? '1' : '0'; //使用cron记录节点
	db_merlinclash["merlinclash_dnsgoclash"] = E("merlinclash_dnsgoclash").checked ? '1' : '0';
	db_merlinclash["merlinclash_dnsclear"] = E("merlinclash_dnsclear").checked ? '1' : '0';
	db_merlinclash["merlinclash_sniffer"] = E("merlinclash_sniffer").checked ? '1' : '0';
	db_merlinclash["merlinclash_tcp_concurrent"] = E("merlinclash_tcp_concurrent").checked ? '1' : '0';
	db_merlinclash["merlinclash_closeproxy"] = E("merlinclash_closeproxy").checked ? '1' : '0';
	db_merlinclash["merlinclash_dashboardswitch"] = E("merlinclash_dashboardswitch").checked ? '1' : '0';
	if(E("merlinclash_dashboardswitch").checked){
		if(!$.trim($('#merlinclash_dashboard_secret').val()) || $('#merlinclash_dashboard_secret').val() == "clash"){
			alert("公网访问面板开启，为了安全请设置复杂密码！！！\r不能为空或者默认密码~");
			return false;
		}
	}
	db_merlinclash["merlinclash_dns_fakeipblack"] = E("merlinclash_dns_fakeipblack").value;
	db_merlinclash["merlinclash_dashboard_secret"] = E("merlinclash_dashboard_secret").value;
	db_merlinclash["merlinclash_dnsplan"] = radio;
	db_merlinclash["merlinclash_cusrule_plan"] = cusrulesel;
	db_merlinclash["merlinclash_clashmode"] = clashmodesel;
	if(db_merlinclash["merlinclash_linuxver"] >= 41){
		db_merlinclash["merlinclash_tproxymode"] = tproxymodesel;
	}else{
		db_merlinclash["merlinclash_tproxymode"] = "closed";
	}
	db_merlinclash["merlinclash_dnshijack"] = dnshijacksel;
	db_merlinclash["merlinclash_links"] = Base64.encode(E("merlinclash_links").value);
	//URL编码后再传入后端
	var links3 = Base64.encode(encodeURIComponent(E("merlinclash_links3").value));
	db_merlinclash["merlinclash_links3"] = links3;
	//queue
	db_merlinclash["merlinclash_queue_switch"] = E("merlinclash_queue_switch").checked ? '1' : '0';
	//20200828+
	db_merlinclash["merlinclash_check_delay_cbox"] = E("merlinclash_check_delay_cbox").checked ? '1' : '0';
	db_merlinclash["merlinclash_auto_delay_cbox"] = E("merlinclash_auto_delay_cbox").checked ? '1' : '0';
	db_merlinclash["merlinclash_customrule_cbox"] = E("merlinclash_customrule_cbox").checked ? '1' : '0';
	db_merlinclash["merlinclash_custom_cbox"] = E("merlinclash_custom_cbox").checked ? '1' : '0';
	db_merlinclash["merlinclash_urltestTolerance_cbox"] = E("merlinclash_urltestTolerance_cbox").checked ? '1' : '0';
	db_merlinclash["merlinclash_interval_cbox"] = E("merlinclash_interval_cbox").checked ? '1' : '0';
	if(E("merlinclash_check_delay_cbox").checked){
		if(!$.trim($('#merlinclash_check_delay_time').val())){
			alert("检查日志重试次数功能开启，重试次数不能为空！");
			return false;
		}
	}
	if(E("merlinclash_auto_delay_cbox").checked){
		if(!$.trim($('#merlinclash_auto_delay_time').val())){
			alert("开机自启推迟功能开启，秒数不能为空！");
			return false;
		}
	}
	if(E("merlinclash_custom_cbox").checked){
		if(!$.trim($('#merlinclash_cus_port').val())){
			alert("自定义端口功能开启，port不能为空！");
			return false;
		}
		if(!$.trim($('#merlinclash_cus_socksport').val())){
			alert("自定义端口功能开启，socks-port不能为空！");
			return false;
		}
		if(!$.trim($('#merlinclash_cus_redirsport').val())){
			alert("自定义端口功能开启，redir-port不能为空！");
			return false;
		}
		if(!$.trim($('#merlinclash_cus_tproxyport').val())){
			alert("自定义端口功能开启，tproxy-port不能为空！");
			return false;
		}
		if(!$.trim($('#merlinclash_cus_dnslistenport').val())){
			alert("自定义端口功能开启，dns监听端口不能为空！");
			return false;
		}
		if(!$.trim($('#merlinclash_cus_dashboardport').val())){
			alert("自定义端口功能开启，面板访问端口不能为空！");
			return false;
		}
	}
	if(E("merlinclash_dnsgoclash").checked){
		if(!$.trim($('#merlinclash_cus_routingmark').val())){
			alert("路由流量标记不能为空！");
			return false;
		}
	}
	db_merlinclash["merlinclash_cus_port"] = E("merlinclash_cus_port").value;
	db_merlinclash["merlinclash_cus_socksport"] = E("merlinclash_cus_socksport").value;
	db_merlinclash["merlinclash_cus_redirsport"] = E("merlinclash_cus_redirsport").value;
	db_merlinclash["merlinclash_cus_tproxyport"] = E("merlinclash_cus_tproxyport").value;
	db_merlinclash["merlinclash_cus_dnslistenport"] = E("merlinclash_cus_dnslistenport").value;
	db_merlinclash["merlinclash_cus_dashboardport"] = E("merlinclash_cus_dashboardport").value;
	db_merlinclash["merlinclash_cus_routingmark"] = E("merlinclash_cus_routingmark").value;
	db_merlinclash["merlinclash_check_delay_time"] = E("merlinclash_check_delay_time").value;
	db_merlinclash["merlinclash_auto_delay_time"] = E("merlinclash_auto_delay_time").value;
	db_merlinclash["merlinclash_watchdog_delay_time"] = E("merlinclash_watchdog_delay_time").value;
	//20200828-
	db_merlinclash["merlinclash_yamlsel"] = E("merlinclash_yamlsel").value;
	yamlsel_tmp1 = E("merlinclash_yamlsel").value;
	db_merlinclash["merlinclash_delyamlsel"] = E("merlinclash_delyamlsel").value;
	//20200630+++
	db_merlinclash["merlinclash_acl4ssrsel"] = E("merlinclash_acl4ssrsel").value;
	//20200630---
	db_merlinclash["merlinclash_clashtarget"] = E("merlinclash_clashtarget").value;
	db_merlinclash["merlinclash_urltestTolerancesel"] = E("merlinclash_urltestTolerancesel").value;
	db_merlinclash["merlinclash_intervalsel"] = E("merlinclash_intervalsel").value;
	if(init_nokpaclcount == 1){
		db_merlinclash["merlinclash_nokpacl_default_mode"] = E("merlinclash_nokpacl_default_mode").value;
		db_merlinclash["merlinclash_nokpacl_default_port"] = E("merlinclash_nokpacl_default_port").value;
	}
	db_merlinclash["merlinclash_nokpacl_method"] = E("merlinclash_nokpacl_method").value;
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_yamltmp.sh", "params":[], "fields": ""};
	intoQueue({
		type: "POST",
		url: "/_api/",
		async: true,
		data: JSON.stringify(postData),
		success: function(response) {
			yamlsel_tmp2 = response.result;
			//更换配置文件，清空节点指定内容
			if(yamlsel_tmp2==null){
				yamlsel_tmp2=yamlsel_tmp1
			}
			if(yamlsel_tmp2!=yamlsel_tmp1){
				db_merlinclash["merlinclash_action"] = "1";
				db_merlinclash["merlinclash_yamlselchange"] = "1";
				//更换配置将模式重置为default 20201208
				db_merlinclash["merlinclash_clashmode"] = "default";
			}
			if(yamlsel_tmp2 == yamlsel_tmp1){
				db_merlinclash["merlinclash_action"] = "1";
				db_merlinclash["merlinclash_yamlselchange"] = "0";
			}
			push_data("clash_config.sh", "start",  getPushData());
		},
		error: function(){
			console.log("ERROR");
		}
	});
}
//过滤不需要提交的数据
function getPushData(){
	var pushData = {};
	$.each(db_merlinclash, (k,v)=>{
		if(v != db_merlinclash_tmp[k]){
			pushData[k] = v;
		}
	})
	return pushData;
}

//push_data方法。调用实时日志显示
function push_data(script, arg, obj, flag){
	if (!flag) showMCLoadingBar();
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": script, "params":[arg], "fields": obj};
	intoQueue({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response){
			if(response.result == id){
				if(flag && flag == "1"){
					refreshpage();
				}else if(flag && flag == "2"){
					//continue;
					//do nothing
				}else{
					if(db_merlinclash["merlinclash_startlog"] == "1" && script == "clash_config.sh" && arg == "start"){
						get_realtime_log_sim();
					}else{
						get_realtime_log();
					}

				}
			}
		}
	});
}
function tabSelect(w) {
	trig=".show-btn" + w;
	for (var i = 0; i <= 99; i++) {
		$('.show-btn' + i).removeClass('active');
		$('#tablet_' + i).hide();
	}
	$('.show-btn' + w).addClass('active');
	$('#tablet_' + w).show();

	var id = parseInt(Math.random() * 100000000);
	var dbus_post={};
	dbus_post["merlinclash_trigger"] = db_merlinclash["merlinclash_trigger"] = trig;
	var postData = {"id": id, "method": "dummy_script.sh", "params":[], "fields": dbus_post};
	intoQueue({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {

		}
	});

}
function dnsplan() {
	var trig = ".show-btn4"
	$(trig).trigger("click");
}
function show_cirtag(){
	if(init_circount == 0){
		if(db_merlinclash["merlinclash_cirswitch"] == "1"){
			E("cirtag").innerHTML = "&nbsp;&nbsp;<em style='color: gold;'>绕行规则总数为：" + db_merlinclash["merlinclash_cirtag"] +"</em>";
		}else{
			E("cirtag").innerHTML = "";
		}
		init_circount = 1;
	}
}
function toggle_func() {
	//首页
	$(".show-btn0").click(
		function() {
			tabSelect(0);
			$('#apply_button').show();
			$('#delallowneracls_button').hide();
		});$(".show-btn88").click(function() {tabSelect(88);$('#apply_button').hide();$('#delallowneracls_button').hide();});
	//配置文件栏
	$(".show-btn1").click(
		function() {
			if(dy_count == 0){
				set_rulemode();
			}
			dy_count = 1;
			tabSelect(1);
			$('#apply_button').hide();
			$('#delallowneracls_button').hide();

		});
	//自定规则栏
	$(".show-btn2").click(
		function() {
			if(init_aclcount == 0){
				refresh_acl_table();
				ipsetyaml_get();
				proxygroup_select();
				var cusrulesel = document.getElementsByName("cusruleplan").innerHTML = getradioval(8);
				CUSRULE_MODE(cusrulesel);
			}
			init_aclcount = 1;
			tabSelect(2);
			$('#apply_button').show();
			$('#delallowneracls_button').show();
		});
	//访问控制栏
	$(".show-btn9").click(
		function() {
			if(init_nokpaclcount == 0){
				refresh_nokpacl_table();
			}
			init_nokpaclcount = 1;
			tabSelect(9);
			$('#apply_button').show();
			$('#delallowneracls_button').hide();
		});
	//高级模式栏
	$(".show-btn3").click(
		function() {
			init_advancedcount = 1;
			if(init_sniffercount == 0){
				get_sniffer();
			}
			init_sniffercount = 1;
			show_cirtag();
			tabSelect(3);
			$('#apply_button').show();
			$('#delallowneracls_button').hide();

		});
	//附加功能栏
	$(".show-btn4").click(
		function() {
			if(select_count == 0){
				// clashbinary_select();
				get_dnsyaml(db_merlinclash["merlinclash_dnsedit_tag"]);
				get_host(db_merlinclash["merlinclash_hostsel"]);

			}
			select_count = 1;
			if(db_merlinclash["merlinclash_updata_date"]){
				E("geoip_updata_date").innerHTML = "<span style='color: gold'>上次更新时间："+db_merlinclash["merlinclash_updata_date"]+"</span>";
			}
			if(db_merlinclash["merlinclash_chnrouteupdate_date"]){
				E("chnroute_updata_date").innerHTML = "<span style='color: gold'>上次更新时间："+db_merlinclash["merlinclash_chnrouteupdate_date"]+"</span>";
			}
			tabSelect(4);
			$('#apply_button').show();
			$('#delallowneracls_button').hide();
		});
	// //当前配置栏
	$(".show-btn6").click(
		function() {
			if(yamlview_count == 0){
				yaml_view();
			}
			yamlview_count = 1;
			tabSelect(6);
			$('#apply_button').hide();
			$('#delallowneracls_button').hide();


		});
	//日志记录栏
	$(".show-btn7").click(
		function() {
			if(log_count == 0){
				node_remark_view();
				get_log();
			}
			log_count = 1;
			tabSelect(7);
			$('#apply_button').hide();
			$('#delallowneracls_button').hide();

		});
	//DC用户栏
	$(".show-btn10").click(
		function() {
			tabSelect(10);
			$('#apply_button').hide();
			$('#delallowneracls_button').hide();
		});
	//显示默认页
	if(db_merlinclash["merlinclash_trigger"]){
		var trig= db_merlinclash["merlinclash_trigger"];
	}else{
		var trig = ".show-btn0"
	}

	$(trig).trigger("click");

}
function get_user_rule() {
	intoQueue({
		url: '/_temp/user.txt',
		type: 'GET',
		cache:false,
		dataType: 'text',
		success: function(res) {
			$('#usertxt').val(res);
		}
	});
}
function get_sniffer(){
	var id = parseInt(Math.random() * 100000000);
	var dbus_post={};
	var postData = {"id": id, "method": "clash_getsniffer.sh", "params":[], "fields": dbus_post};
	intoQueue({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {

		}
	});
}
function get_sniffer_content() {
	intoQueue({
		url: '/_temp/clash_sniffercontent.txt',
		type: 'GET',
		cache:false,
		dataType: 'text',
		success: function(res) {
			$('#snifferrulestxt').val(res);
		}
	});
}
function get_clash_status_front() {
	if (db_merlinclash['merlinclash_enable'] != "1") {
		E("clash_state1").innerHTML = "Clash启动时间 - " + "Waiting...";
		E("clash_state2").innerHTML = "Clash进程 - " + "Waiting...";
		E("clash_state3").innerHTML = "实时守护进程 - " + "Waiting...";
		E("dashboard_state2").innerHTML = "管理面板";
		E("dashboard_state4").innerHTML = "面板密码";
		return false;
	}
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_status.sh", "params":[], "fields": ""};
	intoQueue({
		type: "POST",
		url: "/_api/",
		async: true,
		data: JSON.stringify(postData),
		success: function(response) {
			//console.log(init_count);
			if (init_count==0){
				var arr = response.result.split("@");
				if (arr[0] == "" || arr[1] == "") {
					E("clash_state1").innerHTML = "clash启动时间 - " + "Waiting for first refresh...";
					E("clash_state2").innerHTML = "clash进程 - " + "Waiting for first refresh...";
					E("clash_state3").innerHTML = "实时守护进程 - " + "Waiting for first refresh...";
					E("dashboard_state2").innerHTML = "管理面板";
					E("dashboard_state4").innerHTML = "面板密码";
				} else {
					E("clash_state1").innerHTML = arr[18];
					E("clash_state2").innerHTML = arr[0];
					E("clash_state3").innerHTML = arr[1];
					E("dashboard_state2").innerHTML = arr[5];
					E("dashboard_state4").innerHTML = arr[15];
					yamlsel_tmp2 = arr[7];
					//获取后台返回的IP
					E("ip-ipipnet").innerHTML = arr[20];
					E("ip-ipapi").innerHTML = arr[21];
					E("http-baidu").innerHTML = arr[22] == "连通正常" ? '<span style="color:#6C0">连接正常</span>' :'<span style="color:#ff0000">连接失败</span>';
					<!--E("http-github").innerHTML = arr[23] == "连通正常" ? '<span style="color:#6C0">连接正常</span>' :'<span style="color:#ff0000">连接失败</span>';-->
					E("http-google").innerHTML = arr[23] == "连通正常" ? '<span style="color:#6C0">连接正常</span>' :'<span style="color:#ff0000">连接失败</span>';
					//获取结束
					
					E("sc_version").innerHTML = arr[13];
					var port = arr[3];
					var protocol = location.protocol;
					var zashHref;
					var hostname = document.domain;
					if (hostname.indexOf('.kooldns.cn') != -1 || hostname.indexOf('.ddnsto.com') != -1 || hostname.indexOf('.tocmcc.cn') != -1) {
						var protocol = location.protocol;
						if(hostname.indexOf('.kooldns.cn') != -1){
							hostname = hostname.replace('.kooldns.cn','-clash.kooldns.cn');
						}else if(hostname.indexOf('.ddnsto.com') != -1){
							hostname = hostname.replace('.ddnsto.com','-clash.ddnsto.com');
						}else{
							hostname = hostname.replace('.tocmcc.cn','-clash.tocmcc.cn');
						}

						if(protocol == "https:")
						{
								port = 443;
						}else{
								port = 5000;
						}
						zashHref   =  protocol + '//' + hostname + "/ui/zashboard/#/setup?hostname=" + hostname + "&port=" + port + "&secret=" + arr[16];
						}else{
						zashHref   = "http://"+ location.hostname + ":" +arr[3]+ "/ui/zashboard/#/setup?hostname=" + location.hostname + "&port=" + arr[3] + "&secret=" + arr[16];
					}
					document.getElementById("show_btn88").style.display="";
					$("#zash").html("<a type='button' style='vertical-align: middle; cursor:pointer;' class='ks_btn' href='" + zashHref + "' target='_blank' >访问 ZashBoard-Clash 面板</a>");$("#zash-board").html("<iframe id='zash-frame' style='width:100%;min-height:45rem;border:0;margin-top:1px;' src='"+zashHref+"'></iframe>");

				E("clash_yamlsel").innerHTML = arr[14];
				}
				init_count = 1;
			} else {
				var id2 = parseInt(Math.random() * 100000000);
				var postData = {"id": id2, "method": "clash_status2.sh", "params":[], "fields": ""};
				intoQueue({
					type: "POST",
					url: "/_api/",
					async: true,
					data: JSON.stringify(postData),
					success: function(response) {
						var arr = response.result.split("@");
						if (arr[0] == "" || arr[1] == "") {
							E("clash_state1").innerHTML = "clash启动时间 - " + "Waiting for first refresh...";
							E("clash_state2").innerHTML = "clash进程 - " + "Waiting for first refresh...";
							E("clash_state3").innerHTML = "实时守护进程 - " + "Waiting for first refresh...";
						} else {
							E("clash_state1").innerHTML = arr[2];
							E("clash_state2").innerHTML = arr[0];
							E("clash_state3").innerHTML = arr[1];
							// E("patch_version").innerHTML = arr[4];
						}
					}
				});
			}
			setTimeout("get_clash_status_front();", 5000);
		}
	});
}
//----------------详细状态-----------------------------
function close_proc_status() {
	$("#detail_status").fadeOut(200);
}
function get_proc_status() {
	$("#detail_status").fadeIn(500);
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_proc_status.sh", "params":[], "fields": ""};
	intoQueue({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {
			if(response.result == id){
				write_proc_status();
			}
		}
	});
}
function write_proc_status() {
	intoQueue({
		url: '/_temp/clash_proc_status.txt',
		type: 'GET',
		cache:false,
		dataType: 'text',
		success: function(res) {
			$('#proc_status').val(res);
		}
	});
}
//----------------详细状态-----------------------------
//----------------定时订阅日志-----------------------------
function close_regular_log() {
	$("#regular_log_status").fadeOut(200);
}
function get_regular_log() {
	$("#regular_log_status").fadeIn(500);
	write_regular_log();
}
function write_regular_log() {
	intoQueue({
		url: '/_temp/merlinclash_regular.log',
		type: 'GET',
		cache:false,
		dataType: 'text',
		success: function(res) {
			$('#regular_log').val(res);
		}
	});
}
//----------------定时订阅日志-----------------------------
//----------------DC 订阅 ------------------------------------
function dc_ss_yaml (action) {
	var dbus_post = {};
	var dcss = document.getElementById("dc_ss_1").innerHTML;
	var links_base64 = "";
	links_base64 = Base64.encode(dcss);
	dbus_post["merlinclash_links"] = links_base64;

	dbus_post["merlinclash_uploadrename"] = "dler_ss";
	dbus_post["merlinclash_action"] = action;
	push_data("clash_online_yaml.sh", action,  dbus_post);

}
function dc_v2_yaml (action) {
	var dbus_post = {};
	var dcv2 = document.getElementById("dc_v2_1").innerHTML;
	var links_base64 = "";
	links_base64 = Base64.encode(dcv2);
	dbus_post["merlinclash_links"] = links_base64;

	dbus_post["merlinclash_uploadrename"] = "dler_v2";
	dbus_post["merlinclash_action"] = action;
	push_data("clash_online_yaml.sh", action,  dbus_post);

}
function dc_tj_yaml (action) {
	var dbus_post = {};
	var dctj = document.getElementById("dc_trojan_1").innerHTML;
	var links_base64 = "";
	links_base64 = Base64.encode(dctj);
	dbus_post["merlinclash_links"] = links_base64;

	dbus_post["merlinclash_uploadrename"] = "dler_tj";
	dbus_post["merlinclash_action"] = action;
	push_data("clash_online_yaml.sh", action,  dbus_post);

}
function get_online_yaml(action) {
	var dbus_post = {};updateInputValue();
	if(!$.trim($('#merlinclash_uploadrename').val())){
		alert("重命名框不能为空！");
		return false;
	}
	if(!$.trim($('#merlinclash_links').val())){
		alert("订阅链接不能为空！");
		return false;
	}
	var links_base64 = "";
	links_base64 = Base64.encode(E("merlinclash_links").value);
	dbus_post["merlinclash_links"] = db_merlinclash["merlinclash_links"] = links_base64;
	dbus_post["merlinclash_uploadrename"] = db_merlinclash["merlinclash_uploadrename"] = (E("merlinclash_uploadrename").value);
	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action;
	push_data("clash_online_yaml.sh", action,  dbus_post);

}
function get_online_yaml3(action) {
	var dbus_post = {};
	if(!$.trim($('#merlinclash_uploadrename4').val())){
		alert("重命名框不能为空！");
		return false;
	}
	if(!$.trim($('#merlinclash_links3').val())){
		alert("订阅链接不能为空！");
		return false;
	}
	if(!$.trim($('#merlinclash_subconverter_include').val())){
		var include = "";
	}else{
		var include = encodeURIComponent(E("merlinclash_subconverter_include").value);
	}
	if(!$.trim($('#merlinclash_subconverter_exclude').val())){
		var exclude = "";
	}else{
		var exclude = encodeURIComponent(E("merlinclash_subconverter_exclude").value);
	}
	var links3 = Base64.encode(encodeURIComponent(E("merlinclash_links3").value));
	dbus_post["merlinclash_links3"] = db_merlinclash["merlinclash_links3"] = links3;
	dbus_post["merlinclash_uploadrename4"] = db_merlinclash["merlinclash_uploadrename4"] = (E("merlinclash_uploadrename4").value);
	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action;
	//20200630+++
	dbus_post["merlinclash_acl4ssrsel"] = db_merlinclash["merlinclash_acl4ssrsel"] = E("merlinclash_acl4ssrsel").value;
	if(E("merlinclash_customrule_cbox").checked){
		if(!$.trim($('#merlinclash_acl4ssrsel_cus').val())){
			alert("自定订阅选项不能为空！");
			return false;
		}
		dbus_post["merlinclash_acl4ssrsel_cus"] = db_merlinclash["merlinclash_acl4ssrsel_cus"] = E("merlinclash_acl4ssrsel_cus").value;
	}
	//20210916+++
	if(E("merlinclash_customurl_cbox").checked){
		if(!$.trim($('#merlinclash_uploadiniurl').val())){
			alert("远程配置地址不能为空！");
			return false;
		}
		urlbase64 = Base64.encode(encodeURIComponent(E("merlinclash_uploadiniurl").value));
		dbus_post["merlinclash_uploadiniurl"] = db_merlinclash["merlinclash_uploadiniurl"] = urlbase64;
	}
	dbus_post["merlinclash_customurl_cbox"] = db_merlinclash["merlinclash_customurl_cbox"] = E("merlinclash_customurl_cbox").checked ? '1' : '0';
	dbus_post["merlinclash_clashtarget"] = db_merlinclash["merlinclash_clashtarget"] = E("merlinclash_clashtarget").value;
	dbus_post["merlinclash_subconverter_include"] = db_merlinclash["merlinclash_subconverter_include"] = include;
	dbus_post["merlinclash_subconverter_exclude"] = db_merlinclash["merlinclash_subconverter_exclude"] = exclude;
	dbus_post["merlinclash_subconverter_emoji"] = db_merlinclash["merlinclash_subconverter_emoji"] = E("merlinclash_subconverter_emoji").checked ? '1' : '0';
	dbus_post["merlinclash_subconverter_udp"] = db_merlinclash["merlinclash_subconverter_udp"] = E("merlinclash_subconverter_udp").checked ? '1' : '0';
	dbus_post["merlinclash_subconverter_xudp"] = db_merlinclash["merlinclash_subconverter_xudp"] = E("merlinclash_subconverter_xudp").checked ? '1' : '0';
	dbus_post["merlinclash_subconverter_append_type"] = db_merlinclash["merlinclash_subconverter_append_type"] = E("merlinclash_subconverter_append_type").checked ? '1' : '0';
	dbus_post["merlinclash_subconverter_sort"] = db_merlinclash["merlinclash_subconverter_sort"] = E("merlinclash_subconverter_sort").checked ? '1' : '0';
	dbus_post["merlinclash_subconverter_fdn"] = db_merlinclash["merlinclash_subconverter_fdn"] = E("merlinclash_subconverter_fdn").checked ? '1' : '0';
	//merlinclash_subconverter_scv
	dbus_post["merlinclash_subconverter_scv"] = db_merlinclash["merlinclash_subconverter_scv"] = E("merlinclash_subconverter_scv").checked ? '1' : '0';
	dbus_post["merlinclash_subconverter_tfo"] = db_merlinclash["merlinclash_subconverter_tfo"] = E("merlinclash_subconverter_tfo").checked ? '1' : '0';
	push_data("clash_online_yaml4.sh", action,  dbus_post);

}
function get_online_yaml4(action) {
	var dbus_post = {};
	if(!$.trim($('#merlinclash_dc_subconverter_include').val())){
		var include = "";
	}else{
		var include = encodeURIComponent(E("merlinclash_dc_subconverter_include").value);
	}
	if(!$.trim($('#merlinclash_dc_subconverter_exclude').val())){
		var exclude = "";
	}else{
		var exclude = encodeURIComponent(E("merlinclash_dc_subconverter_exclude").value);
	}
	var dcss = document.getElementById("dc_ss_1").innerHTML;
	var dcv2 = document.getElementById("dc_v2_1").innerHTML;
	var dctj = document.getElementById("dc_trojan_1").innerHTML;
	if(dcss == "null"){
		dcss = ""
	}
	if(dcv2 == "null"){
		dcv2 = ""
	}
	if(dctj == "null"){
		dctj = ""
	}
	var links3 = dcss + "|" + dcv2 + "|" + dctj;
	//20210916+++
	if(E("merlinclash_dc_customurl_cbox").checked){
		if(!$.trim($('#merlinclash_dc_uploadiniurl').val())){
			alert("远程配置地址不能为空！");
			return false;
		}
		dcurlbase64 = Base64.encode(encodeURIComponent(E("merlinclash_dc_uploadiniurl").value));
		dbus_post["merlinclash_dc_uploadiniurl"] = db_merlinclash["merlinclash_dc_uploadiniurl"] = dcurlbase64;
	}
	dbus_post["merlinclash_dc_customurl_cbox"] = db_merlinclash["merlinclash_dc_customurl_cbox"] = E("merlinclash_dc_customurl_cbox").checked ? '1' : '0';

	//20210916---
	//links3 = encodeURIComponent(links3);
	links3 = Base64.encode(encodeURIComponent(links3));
	dbus_post["merlinclash_dc_links3"] = links3;
	dbus_post["merlinclash_dc_uploadrename4"] = "dler_3in1";
	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action;
	//20200630+++
	dbus_post["merlinclash_dc_acl4ssrsel"] = db_merlinclash["merlinclash_dc_acl4ssrsel"] = E("merlinclash_dc_acl4ssrsel").value;
	//20200804
	dbus_post["merlinclash_dc_clashtarget"] = db_merlinclash["merlinclash_dc_clashtarget"] = E("merlinclash_dc_clashtarget").value;
	dbus_post["merlinclash_dc_subconverter_include"] = db_merlinclash["merlinclash_dc_subconverter_include"] = include;
	dbus_post["merlinclash_dc_subconverter_exclude"] = db_merlinclash["merlinclash_dc_subconverter_exclude"] = exclude;
	dbus_post["merlinclash_dc_subconverter_emoji"] = db_merlinclash["merlinclash_dc_subconverter_emoji"] = E("merlinclash_dc_subconverter_emoji").checked ? '1' : '0';
	dbus_post["merlinclash_dc_subconverter_udp"] = db_merlinclash["merlinclash_dc_subconverter_udp"] = E("merlinclash_dc_subconverter_udp").checked ? '1' : '0';
	dbus_post["merlinclash_dc_subconverter_append_type"] = db_merlinclash["merlinclash_dc_subconverter_append_type"] = E("merlinclash_dc_subconverter_append_type").checked ? '1' : '0';
	dbus_post["merlinclash_dc_subconverter_sort"] = db_merlinclash["merlinclash_dc_subconverter_sort"] = E("merlinclash_dc_subconverter_sort").checked ? '1' : '0';
	dbus_post["merlinclash_dc_subconverter_fdn"] = db_merlinclash["merlinclash_dc_subconverter_fdn"] = E("merlinclash_dc_subconverter_fdn").checked ? '1' : '0';
	//merlinclash_subconverter_scv
	dbus_post["merlinclash_dc_subconverter_scv"] = db_merlinclash["merlinclash_dc_subconverter_scv"] = E("merlinclash_dc_subconverter_scv").checked ? '1' : '0';
	dbus_post["merlinclash_dc_subconverter_tfo"] = db_merlinclash["merlinclash_dc_subconverter_tfo"] = E("merlinclash_dc_subconverter_tfo").checked ? '1' : '0';
	push_data("clash_online_yaml4.sh", action,  dbus_post);


}
//------------------------------------导出全局数据 BEGIN--------------------------------------------
function down_clashdata(arg) {
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_downdata.sh", "params":[arg], "fields": "" };
	intoQueue({
		type: "POST",
		url: "/_api/",
		async: true,
		cache:false,
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response){
			if(response.result == id){
				if(arg == 1){
					var downloadA = document.createElement('a');
					var josnData = {};
					var a = "http://"+window.location.hostname+"/_temp/"+"clash_backup.tar.gz"
					var blob = new Blob([JSON.stringify(josnData)],{type : 'application/json'});
					downloadA.href = a;
					downloadA.download = "clash_backup.tar.gz";
					downloadA.click();
					window.URL.revokeObjectURL(downloadA.href);
				}
			}
		}
	});
}
function upload_clashdata() {
	if(!$.trim($('#clashdata').val())){
		alert("请先选择文件");
		return false;
	}
	layer.confirm('<li>请确保补丁文件合法！仍要上传安装补丁吗？</li>', {
		shade: 0.8,
	}, function(index) {
		var filename = $("#clashdata").val();
		filename = filename.split('\\');
		filename = filename[filename.length - 1];
		var lastindex = filename.lastIndexOf('.')
		filelast = filename.substring(lastindex)
		if (filelast != ".gz" ) {
			console.log(filename);
			console.log(filelast);
			alert('上传文件格式不正确！');

			return false;
		}
		E('clashdata_info').style.display = "none";
		var formData = new FormData();
		formData.append("clash_backup.tar.gz", $('#clashdata')[0].files[0]);
		intoQueue({
			url: '/_upload',
			type: 'POST',
			cache: false,
			data: formData,
			processData: false,
			contentType: false,
			complete: function(res) {
				if (res.status == 200) {
					E('clashdata_info').style.display = "block";
					restore_clash_data();
				}
			}
		});
		layer.close(index);
		return true;
	}, function(index) {
		layer.close(index);
		return false;
	});
}
function restore_clash_data() {
	showMCLoadingBar();
	var dbus_post = {};
	var id = parseInt(Math.random() * 100000000);
	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action = 27;
	push_data("clash_downdata.sh", action,  dbus_post);
}
//------------------------------------导出全局数据 END--------------------------------------------
//------------------------------------导出自定义规则以及还原 BEGIN--------------------------------------------
function down_clashrestorerule(arg) {
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_downrule.sh", "params":[arg], "fields": "" };
	intoQueue({
		type: "POST",
		url: "/_api/",
		async: true,
		cache:false,
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response){
			if(response.result == id){
				if(arg == 1){
					var downloadA = document.createElement('a');
					var josnData = {};
					var a = "http://"+window.location.hostname+"/_temp/"+"clash_rulebackup.tar.gz"
					var blob = new Blob([JSON.stringify(josnData)],{type : 'application/json'});
					downloadA.href = a;
					downloadA.download = "clash_rulebackup.tar.gz";
					downloadA.click();
					window.URL.revokeObjectURL(downloadA.href);
				}
			}
		}
	});
}
function upload_clashrestorerule() {
	var filename = $("#clashrestorerule").val();
	filename = filename.split('\\');
	filename = filename[filename.length - 1];
	var lastindex = filename.lastIndexOf('.')
	filelast = filename.substring(lastindex)

	if (filelast != ".gz" ) {
		alert('上传备份文件格式不正确！');
		return false;
	}
	E('clashrestorerule_info').style.display = "none";
	var formData = new FormData();
	formData.append("clash_rulebackup.tar.gz", $('#clashrestorerule')[0].files[0]);
	intoQueue({
		url: '/_upload',
		type: 'POST',
		cache: false,
		data: formData,
		processData: false,
		contentType: false,
		complete: function(res) {
			if (res.status == 200) {
				E('clashrestorerule_info').style.display = "block";
				restore_clash_rule();
			}
		}
	});
}
function restore_clash_rule() {
	showMCLoadingBar();
	var dbus_post = {};
	var id = parseInt(Math.random() * 100000000);
	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action = 23;
	push_data("clash_downrule.sh", action,  dbus_post);
}
//------------------------------------导出自定义规则以及还原 END--------------------------------------------
//------------------------------------导出绕行设置以及还原 BEGIN--------------------------------------------
function down_passdevice(arg) {
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_downpassdevice.sh", "params":[arg], "fields": "" };
	intoQueue({
		type: "POST",
		url: "/_api/",
		async: true,
		cache:false,
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response){
			if(response.result == id){
				if(arg == 1){
					var downloadA = document.createElement('a');
					var josnData = {};
					var a = "http://"+window.location.hostname+"/_temp/"+"clash_passdevicebackup.sh"
					var blob = new Blob([JSON.stringify(josnData)],{type : 'application/json'});
					downloadA.href = a;
					downloadA.download = "clash_passdevicebackup.sh";
					downloadA.click();
					window.URL.revokeObjectURL(downloadA.href);
				}
			}
		}
	});
}
function upload_passdevice() {
	var filename = $("#passdevice").val();
	filename = filename.split('\\');
	filename = filename[filename.length - 1];
	var filelast = filename.split('.');
	filelast = filelast[filelast.length - 1];
	if (filelast != "sh" ) {
		alert('备份文件格式不正确！');
		return false;
	}
	E('passdevice_info').style.display = "none";
	var formData = new FormData();
	formData.append("clash_passdevicebackup.sh", $('#passdevice')[0].files[0]);
	intoQueue({
		url: '/_upload',
		type: 'POST',
		cache: false,
		data: formData,
		processData: false,
		contentType: false,
		complete: function(res) {
			if (res.status == 200) {
				E('passdevice_info').style.display = "block";
				restore_passdevice();
			}
		}
	});
}
function restore_passdevice() {
	showMCLoadingBar();
	var dbus_post = {};
	var id = parseInt(Math.random() * 100000000);
	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action = 24;
	push_data("clash_downpassdevice.sh", action,  dbus_post);
}
//------------------------------------导出绕行设置以及还原 END-------------------------------------------
function ssconvert(action) {
	var dbus_post = {};
	if(!$.trim($('#merlinclash_uploadrename3').val())){
		alert("重命名框不能为空！");
		return false;
	}
	dbus_post["merlinclash_uploadrename3"] = db_merlinclash["merlinclash_uploadrename3"] = (E("merlinclash_uploadrename3").value);
	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action;
	push_data("clash_online_yaml3.sh", action,  dbus_post);
}
//------------------------------------------删除配置 BEGIN--------------------------------------
function del_yaml_sel(action) {
	var dbus_post = {};
	if(!$.trim($('#merlinclash_delyamlsel').val())){
		alert("配置文件不能为空！");
		return false;
	}
	if(E("merlinclash_delyamlsel").value == db_merlinclash["merlinclash_yamlsel"] && E("clash_state2").innerHTML != "Clash进程 - " + "Waiting..."){
		alert("选择的配置文件为当前使用文件，不予删除！");
		return false;
	}
	dbus_post["merlinclash_delyamlsel"] = db_merlinclash["merlinclash_delyamlsel"] = (E("merlinclash_delyamlsel").value);
	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = "4"
	push_data("clash_delyamlsel.sh", action, dbus_post);
}
//------------------------------------------删除配置 END--------------------------------------
//------------------------------------------更新yaml BEGIN--------------------------------------
function update_yaml_sel(action) {
	var dbus_post = {};
	if(!$.trim($('#merlinclash_delyamlsel').val())){
		alert("请选择一个配置文件！");
		return false;
	}
	dbus_post["merlinclash_delyamlsel"] = db_merlinclash["merlinclash_delyamlsel"] = (E("merlinclash_delyamlsel").value);
	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = "26"
	push_data("clash_updateyamlsel.sh", action, dbus_post);
}
///------------------------------------------更新yaml END--------------------------------------
//----------------------------下载配置 BEGIN-----------------------------
function download_yaml_sel(action) {
	//下载前清空/tmp/upload文件夹下的yaml格式文件
	if(!$.trim($('#merlinclash_delyamlsel').val())){
		alert("配置文件不能为空！");
		return false;
	}
	var dbus_post = {};
	clear_yaml();
	dbus_post["merlinclash_delyamlsel"] = db_merlinclash["merlinclash_delyamlsel"] = (E("merlinclash_delyamlsel").value);
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_downyamlsel.sh", "params":[action], "fields": dbus_post};
	var yamlname=""
	intoQueue({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {
			yamlname = response.result;
			download(yamlname);
		}
	});
}
function download(yamlname) {
	var downloadA = document.createElement('a');
	var josnData = {};
	var a = "http://"+window.location.hostname+"/_temp/"+yamlname
	var blob = new Blob([JSON.stringify(josnData)],{type : 'application/json'});
	downloadA.href = a;
	downloadA.download = yamlname;
	downloadA.click();
	window.URL.revokeObjectURL(downloadA.href);
}
//----------------------------下载配置 END-----------------------------
//20200904下载HOST
function download_host() {
	var dbus_post = {};
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_downhost.sh", "params":[], "fields": dbus_post};
	intoQueue({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {
			hostfile = response.result;
			downloadhostfile(hostfile);
		}
	});
}
//20210415 删除HOST
//------------------------------------------删除HOST BEGIN--------------------------------------
function del_host_sel() {
	var dbus_post = {};
	if(!$.trim($('#merlinclash_hostsel').val())){
		alert("HOST文件不能为空！");
		return false;
	}
	if(E("merlinclash_hostsel").value == "default"){
		alert("默认host文件不予删除！");
		return false;
	}
	if(E("merlinclash_hostsel").value == db_merlinclash["merlinclash_hostsel_tmp"]){
		alert("当前使用的host文件不予删除！");
		return false;
	}
	dbus_post["merlinclash_hostsel"] = db_merlinclash["merlinclash_hostsel"] = (E("merlinclash_hostsel").value);
	action = dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = "32"
	push_data("clash_delhostsel.sh", action, dbus_post);
}
//------------------------------------------删除HOST END--------------------------------------

function downloadhostfile() {
	var downloadA = document.createElement('a');
	var josnData = {};
	var a = "http://"+window.location.hostname+"/_temp/"+hostfile
	var blob = new Blob([JSON.stringify(josnData)],{type : 'application/json'});
	downloadA.href = a;
	downloadA.download = hostfile;
	downloadA.click();
	window.URL.revokeObjectURL(downloadA.href);
}
//20200904
function yaml_view() {
	intoQueue({
		url: '/_temp/view.txt',
		type: 'GET',
		dataType: 'html',
		async: true,
		cache:false,
		success: function(response) {
			var retArea = E("yaml_content1");
			if (response.search("BBABBBBC") != -1) {
				retArea.value = response.replace("BBABBBBC", " ");
				var pageH = parseInt(E("FormTitle").style.height.split("px")[0]);
				if(pageH){
					autoTextarea(E("yaml_content1"), 0, (pageH - 308));
				}else{
					autoTextarea(E("yaml_content1"), 0, 980);
				}
				return true;
			}
			//加行号
			var contents = response.split('\n')
			var finalContent= '';
			for(var i = 0; i <contents.length; i++) {
				finalContent += i + "  " + contents[i] + '\n';
			}

			retArea.value = finalContent;
			_responseLen = response.length;
		},
		error: function(xhr) {
			E("yaml_content1").value = "获取配置文件信息失败！";
		}
	});
}
//在线获取广告区
function notice_show() {
	intoQueue({
		url: 'https://raw.githubusercontent.com/fastbash/MerlinClash2/master/push_message.json.js',
		type: 'GET',
		dataType: 'json',
		success: function(res) {
			if(res.content1){
				$("#showmsg1").html("<i>"+res.content1+"</i>");
			}
			if(res.content2){
				$("#showmsg2").html("<i>"+res.content2+"</i>");
			}
			if(res.content3){
				$("#showmsg3").html("<i>"+res.content3+"</i>");
			}
			if(res.content4){
				$("#showmsg4").html("<i>"+res.content4+"</i>");
			}
			if(res.content5){
				$("#showmsg5").html("<i>"+res.content5+"</i>");
			}
			if(res.content6){
				$("#showmsg6").html("<i>"+res.content6+"</i>");
			}
			if(res.content7){
				$("#showmsg7").html("<i>"+res.content7+"</i>");
			}
			if(res.content8){
				$("#showmsg8").html("<i>"+res.content8+"</i>");
			}
			if(res.content9){
				$("#showmsg9").html("<i>"+res.content9+"</i>");
			}
			if(res.content10){
				$("#showmsg10").html("<i>"+res.content10+"</i>");
			}
		}
	});
}
//检查版本更新

function node_remark_view() {
	var txt = E("merlinclash_yamlsel").value;
	intoQueue({
		url: '/_temp/merlinclash_node_mark.log',
		type: 'GET',
		dataType: 'html',
		async: true,
		cache:false,
		success: function(response) {
			var retArea = E("nodes_content1");
			if (response.search("BBABBBBC") != -1) {
				retArea.value = response.replace("BBABBBBC", " ");
				var pageH = parseInt(E("FormTitle").style.height.split("px")[0]);
				if(pageH){
					autoTextarea(E("nodes_content1"), 0, (pageH - 308));
				}else{
					autoTextarea(E("nodes_content1"), 0, 980);
				}
				return true;
			}
			retArea.value = response;
			_responseLen = response.length;
		},
		error: function(xhr) {
			E("nodes_content1").value = "获取节点还原信息失败！";
		}
	});
}
function get_log() {
	intoQueue({
		url: '/_temp/merlinclash_log.txt',
		type: 'GET',
		dataType: 'html',
		async: true,
		cache:false,
		success: function(response) {
			var retArea = E("log_content1");
			if (response.search("BBABBBBC") != -1) {
				retArea.value = response.replace("BBABBBBC", " ");
				var pageH = parseInt(E("FormTitle").style.height.split("px")[0]);
				if(pageH){
					autoTextarea(E("log_content1"), 0, (pageH - 308));
				}else{
					autoTextarea(E("log_content1"), 0, 980);
				}
				return true;
			}
			if (_responseLen == response.length) {
				noChange++;
			} else {
				noChange = 0;
			}
			if (noChange > 5) {
				return false;
			} else {
				setTimeout("get_log();", 300);
			}
			retArea.value = response;
			_responseLen = response.length;
		},
		error: function(xhr) {
			E("log_content1").value = "获取日志失败！";
		}
	});
}
function count_down_close1() {
	if (x == "0") {
		hideMCLoadingBar();
	}
	if (x < 0) {
		E("ok_button1").value = "手动关闭"
		return false;
	}
	E("ok_button1").value = "自动关闭（" + x + "）"
	--x;
	setTimeout("count_down_close1();", 1000);
}
function get_realtime_log() {
	intoQueue({
		url: '/_temp/merlinclash_log.txt',
		type: 'GET',
		async: true,
		cache: false,
		dataType: 'text',
		success: function(response) {
			var retArea = E("log_content3");
			if (response.search("BBABBBBC") != -1) {
				retArea.value = response.replace("BBABBBBC", " ");
				E("ok_button").style.display = "";
				retArea.scrollTop = retArea.scrollHeight;
				count_down_close1();
				return true;
			}
			if (_responseLen == response.length) {
				noChange++;
			} else {
				noChange = 0;
			}
			if (noChange > 1000) {
				return false;
			} else {
				setTimeout("get_realtime_log();", 500);
			}
			retArea.value = response.replace("BBABBBBC", " ");
			retArea.scrollTop = retArea.scrollHeight;
			_responseLen = response.length;
		},
		error: function() {
			setTimeout("get_realtime_log();", 500);
		}
	});
}
function get_realtime_log_sim() {
	intoQueue({
		url: '/_temp/merlinclash_simlog.txt',
		type: 'GET',
		async: true,
		cache: false,
		dataType: 'text',
		success: function(response) {
			var retArea = E("log_content3");
			if (response.search("BBABBBBC") != -1) {
				retArea.value = response.replace("BBABBBBC", " ");
				E("ok_button").style.display = "";
				retArea.scrollTop = retArea.scrollHeight;
				count_down_close1();
				return true;
			}
			if (_responseLen == response.length) {
				noChange++;
			} else {
				noChange = 0;
			}
			if (noChange > 1000) {
				return false;
			} else {
				setTimeout("get_realtime_log_sim();", 3000);
			}
			retArea.value = response.replace("BBABBBBC", " ");
			retArea.scrollTop = retArea.scrollHeight;
			_responseLen = response.length;
		},
		error: function() {
			setTimeout("get_realtime_log_sim();", 1000);
		}
	});
}
//
function getradioval(sel_tmp) {
	if (sel_tmp == "1"){
		var radio = document.getElementsByName("dnsplan");
		for(i = 0; i< radio.length; i++){
			if(radio[i].checked){
				return radio[i].value
			}
		}
	}
	if (sel_tmp == "2"){
		var yamlsel = document.getElementsByName("yamlsel");
		for(i = 0; i< yamlsel.length; i++){
			if(yamlsel[i].checked){
				return yamlsel[i].value
			}
		}
	}
	if (sel_tmp == "3"){
		var clashmodesel = document.getElementsByName("clashmode");
		for(i = 0; i< clashmodesel.length; i++){
			if(clashmodesel[i].checked){
				return clashmodesel[i].value
			}
		}
	}
	if (sel_tmp == "4"){
		var tproxymodesel = document.getElementsByName("tproxymode");
		for(i = 0; i< tproxymodesel.length; i++){
			if(tproxymodesel[i].checked){
				return tproxymodesel[i].value
			}
		}
	}
	if (sel_tmp == "5"){
		var iptablessel = document.getElementsByName("iptablessel");
		for(i = 0; i< iptablessel.length; i++){
			if(iptablessel[i].checked){
				return iptablessel[i].value
			}
		}
	}
	if (sel_tmp == "6"){
		var unblockplan = document.getElementsByName("unblockplan");
		for(i = 0; i< unblockplan.length; i++){
			if(unblockplan[i].checked){
				return unblockplan[i].value
			}
		}
	}
	if (sel_tmp == "7"){
		var dnshijacksel = document.getElementsByName("dnshijack");
		for(i = 0; i< dnshijacksel.length; i++){
			if(dnshijacksel[i].checked){
				return dnshijacksel[i].value
			}
		}
	}
	if (sel_tmp == "8"){
		var cusruleplan = document.getElementsByName("cusruleplan");
		for(i = 0; i< cusruleplan.length; i++){
			if(cusruleplan[i].checked){
				return cusruleplan[i].value
			}
		}
	}
	if (sel_tmp == "9"){
		var subscribeplan = document.getElementsByName("subscribeplan");
		for(i = 0; i< subscribeplan.length; i++){
			if(subscribeplan[i].checked){
				return subscribeplan[i].value
			}
		}
	}
}
function reload_Soft_Center() {
	location.href = "/Module_Softcenter.asp";
}
function load_cron_params() {

	for (var i = 0; i < 24; i++){
		var _tmp = [];
		var _tmp0 = [];
		_i = String(i)
		_tmp0 = _i;
		_tmp = _i + "时";
		$("#merlinclash_select_hour").append("<option value='"+_tmp0+"' >"+_tmp+"</option>");
		$("#merlinclash_select_regular_hour").append("<option value='"+_tmp0+"' >"+_tmp+"</option>");
		$("#merlinclash_select_clash_restart_hour").append("<option value='"+_tmp0+"' >"+_tmp+"</option>");
	}

	for (var i = 0; i < 61; i++){
		var _tmp = [];
		var _tmp0 = [];
		_i = String(i)
		_tmp0 = _i;
		_tmp = _i + "分";
		$("#merlinclash_select_minute").append("<option value='"+_tmp0+"' >"+_tmp+"</option>");
		$("#merlinclash_select_regular_minute").append("<option value='"+_tmp0+"' >"+_tmp+"</option>");
		$("#merlinclash_select_clash_restart_minute").append("<option value='"+_tmp0+"' >"+_tmp+"</option>");
	}
	var option_rebw = [["1", "一"], ["2", "二"], ["3", "三"], ["4", "四"], ["5", "五"], ["6", "六"], ["7", "日"]];
	for (var i = 0; i < option_rebw.length; i++){
		var _tmp = [];
		var _tmp0 = [];
		_i = String(i)
		_tmp = option_rebw[_i];
		_tmp1 = _tmp[1];
		_tmp0 = _tmp[0];
		$("#merlinclash_select_week").append("<option value='"+_tmp0+"' >"+_tmp1+"</option>");
		$("#merlinclash_select_regular_week").append("<option value='"+_tmp0+"' >"+_tmp1+"</option>");
		$("#merlinclash_select_clash_restart_week").append("<option value='"+_tmp0+"' >"+_tmp1+"</option>");
	}
	var option_trit = [["2", "2分钟"], ["5", "5分钟"], ["10", "10分钟"], ["15", "15分钟"], ["20", "20分钟"], ["25", "25分钟"], ["30", "30分钟"], ["1", "1小时"], ["3", "3小时"], ["6", "6小时"], ["12", "12小时"]];
	for (var i = 0; i < option_trit.length; i++){
		var _tmp = [];
		var _tmp0 = [];
		_i = String(i)
		_tmp = option_trit[_i];
		_tmp1 = _tmp[1];
		_tmp0 = _tmp[0];
		$("#merlinclash_select_regular_minute_2").append("<option value='"+_tmp0+"' >"+_tmp1+"</option>");
		$("#merlinclash_select_clash_restart_minute_2").append("<option value='"+_tmp0+"' >"+_tmp1+"</option>");
	}
	for (var i = 1; i < 32; i++){
		var _tmp = [];
		var _tmp0 = [];
		_i = String(i)
		_tmp0 = _i;
		_tmp = _i + "日";
		$("#merlinclash_select_day").append("<option value='"+_tmp0+"' >"+_tmp+"</option>");
		$("#merlinclash_select_regular_day").append("<option value='"+_tmp0+"' >"+_tmp+"</option>");
		$("#merlinclash_select_clash_restart_day").append("<option value='"+_tmp0+"' >"+_tmp+"</option>");
	}
}
function show_job() {
	var option_rebw = [["1", "一"], ["2", "二"], ["3", "三"], ["4", "四"], ["5", "五"], ["6", "六"], ["7", "日"]];
	if (E("merlinclash_select_regular_subscribe").value == "1" ){
		$('#merlinclash_select_regular_hour').hide();
		$('#merlinclash_select_regular_minute').hide();
		$('#merlinclash_select_regular_day').hide();
		$('#merlinclash_select_regular_week').hide();
		$('#merlinclash_select_regular_minute_2').hide();
	}
	else if (E("merlinclash_select_regular_subscribe").value == "2" ){
		$('#merlinclash_select_regular_hour').show();
		$('#merlinclash_select_regular_minute').show();
		$('#merlinclash_select_regular_week').hide();
		$('#merlinclash_select_regular_day').hide();
		$('#merlinclash_select_regular_minute_2').hide();
	}
	else if (E("merlinclash_select_regular_subscribe").value == "3" ){
		$('#merlinclash_select_regular_hour').show();
		$('#merlinclash_select_regular_minute').show();
		$('#merlinclash_select_regular_day').hide();
		$('#merlinclash_select_regular_week').show();
		$('#merlinclash_select_regular_minute_2').hide();
	}
	else if (E("merlinclash_select_regular_subscribe").value == "4" ){
		$('#merlinclash_select_regular_day').show();
		$('#merlinclash_select_regular_hour').show();
		$('#merlinclash_select_regular_minute').show();
		$('#merlinclash_select_regular_week').hide();
		$('#merlinclash_select_regular_minute_2').hide();
	}
	else if (E("merlinclash_select_regular_subscribe").value == "5" ){
		$('#merlinclash_select_regular_day').hide();
		$('#merlinclash_select_regular_hour').hide();
		$('#merlinclash_select_regular_minute').hide();
		$('#merlinclash_select_regular_week').hide();
		$('#merlinclash_select_regular_minute_2').show();
	}
	if (E("merlinclash_select_clash_restart").value == "1" ){
		$('#merlinclash_select_clash_restart_hour').hide();
		$('#merlinclash_select_clash_restart_minute').hide();
		$('#merlinclash_select_clash_restart_day').hide();
		$('#merlinclash_select_clash_restart_week').hide();
		$('#merlinclash_select_clash_restart_minute_2').hide();
	}
	else if (E("merlinclash_select_clash_restart").value == "2" ){
		$('#merlinclash_select_clash_restart_hour').show();
		$('#merlinclash_select_clash_restart_minute').show();
		$('#merlinclash_select_clash_restart_week').hide();
		$('#merlinclash_select_clash_restart_day').hide();
		$('#merlinclash_select_clash_restart_minute_2').hide();
	}
	else if (E("merlinclash_select_clash_restart").value == "3" ){
		$('#merlinclash_select_clash_restart_hour').show();
		$('#merlinclash_select_clash_restart_minute').show();
		$('#merlinclash_select_clash_restart_day').hide();
		$('#merlinclash_select_clash_restart_week').show();
		$('#merlinclash_select_clash_restart_minute_2').hide();
	}
	else if (E("merlinclash_select_clash_restart").value == "4" ){
		$('#merlinclash_select_clash_restart_day').show();
		$('#merlinclash_select_clash_restart_hour').show();
		$('#merlinclash_select_clash_restart_minute').show();
		$('#merlinclash_select_clash_restart_week').hide();
		$('#merlinclash_select_clash_restart_minute_2').hide();
	}
	else if (E("merlinclash_select_clash_restart").value == "5" ){
		$('#merlinclash_select_clash_restart_day').hide();
		$('#merlinclash_select_clash_restart_hour').hide();
		$('#merlinclash_select_clash_restart_minute').hide();
		$('#merlinclash_select_clash_restart_week').hide();
		$('#merlinclash_select_clash_restart_minute_2').show();
	}
}
function dc_login() {
	var dbus_post = {};
	dbus_post["merlinclash_dc_name"] = db_merlinclash["merlinclash_dc_name"] = Base64.encode(encodeURIComponent(E("merlinclash_dc_name").value));
	dbus_post["merlinclash_dc_passwd"] = db_merlinclash["merlinclash_dc_passwd"] = Base64.encode(encodeURIComponent(E("merlinclash_dc_passwd").value));
	var arg="login"
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_dclogin.sh", "params":[arg], "fields": dbus_post};
	intoQueue({
		type: "POST",
		url: "/_api/",
		async: true,
		data: JSON.stringify(postData),
		success: function(response) {
			var arr = response.result;
			if (arr != "200"){
				alert("登陆用户名/密码有误。");
				return false;
			} else{
				dc_info();
			}
		}
	});
}

function dc_logout() {
	var dbus_post = {};
	dbus_post["merlinclash_dc_name"] = db_merlinclash["merlinclash_dc_name"] = Base64.encode(encodeURIComponent(E("merlinclash_dc_name").value));
	dbus_post["merlinclash_dc_passwd"] = db_merlinclash["merlinclash_dc_passwd"] = Base64.encode(encodeURIComponent(E("merlinclash_dc_passwd").value));
	var arg="logout"
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_dclogin.sh", "params":[arg], "fields": dbus_post};
	intoQueue({
		type: "POST",
		url: "/_api/",
		async: true,
		data: JSON.stringify(postData),
		success: function(response) {
			tabSelect(10);
			$('#dlercloud_login').show();
			$('#dlercloud_content').hide();
		}
	});

}
//初始化页面时决定栏目显示哪个div层
function dc_init() {
	//初次未登录，显示登陆栏，此时token为空。
	if(db_merlinclash["merlinclash_dc_token"] == "" || db_merlinclash["merlinclash_dc_token"] == null){
		$('#dlercloud_login').show();
		$('#dlercloud_content').hide();
		return false;
	}
	//token失效，退回登陆栏；有效则重新获取最新的套餐信息
	if(db_merlinclash["merlinclash_dc_token"]){
		var dbus_post = {};
		var arg="token"
		var id = parseInt(Math.random() * 100000000);
		var postData = {"id": id, "method": "clash_dclogin.sh", "params":[arg], "fields": dbus_post};
		intoQueue({
			type: "POST",
			url: "/_api/",
			async: true,
			data: JSON.stringify(postData),
			success: function(response) {
				var arr = response.result.split("@@");
				if (arr[0] != "200"){
					alert("DlerCloud用户/密码错，请重新登陆");
					$('#dlercloud_login').show();
					$('#dlercloud_content').hide();
					return false;
				} else{
					E("dc_name").innerHTML = arr[1];
					E("dc_token").innerHTML = arr[10];
					E("dc_money").innerHTML = arr[4];
					E("dc_affmoney").innerHTML = arr[11];
					E("dc_integral").innerHTML = arr[12];
					E("dc_plan").innerHTML = arr[2];
					E("dc_plantime").innerHTML = arr[3];
					E("dc_usedTraffic").innerHTML = arr[5];
					E("dc_unusedTraffic").innerHTML = arr[6];
					E("dc_ss").innerHTML = arr[7];
					E("dc_v2").innerHTML = arr[8];
					E("dc_trojan").innerHTML = arr[9];
					$('#dlercloud_login').hide();
					$('#dlercloud_content').show();
					dc_info_show();
					return false;
				}
			}
		});
	}
}

function open_sniffer(){
	//
	get_sniffer_content();
	$("#snifferrules_settings").fadeIn(200);
}
function close_sniffer(){
	$("#snifferrules_settings").fadeOut(200);
}
function dc_info() {
	tabSelect(10);
	dc_info_show();
	$('#dlercloud_login').hide();
	$('#dlercloud_content').show();

}

function dc_info_show() {
	var dbus_post = {};
	var arg="info"
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_dclogin.sh", "params":[arg], "fields": dbus_post};
	intoQueue({
		type: "POST",
		url: "/_api/",
		async: true,
		data: JSON.stringify(postData),
		success: function(response) {
			var arr = response.result.split("@@");
			if (arr[0] != "200"){
				alert(arr[0]);
				return false;
			} else{
				E("dc_name").innerHTML = arr[1];
				E("dc_token").innerHTML = arr[10];
				E("dc_money").innerHTML = arr[4];
				E("dc_affmoney").innerHTML = arr[11];
				E("dc_integral").innerHTML = arr[12];
				E("dc_plan").innerHTML = arr[2];
				E("dc_plantime").innerHTML = arr[3];
				E("dc_usedTraffic").innerHTML = arr[5];
				E("dc_unusedTraffic").innerHTML = arr[6];
				E("dc_ss").innerHTML = arr[7];
				E("dc_v2").innerHTML = arr[8];
				E("dc_trojan").innerHTML = arr[9];

			}
		}
	});
}
function subc_addr_change(obj) {
	var value = $(obj).find('option:selected').text();
	switch (value){

		case "天枢互联":
		document.getElementById('merlinclash_subconverter_addr').value='https://api.tshl.us/';
		document.getElementById("merlinclash_subconverter_addr").readOnly = true;
		document.getElementById("merlinclash_subconverter_addr_cus").style.display = "none";
		document.getElementById("merlinclash_subconverter_addr").style.display = "";
		break;

		case "品云":
		document.getElementById('merlinclash_subconverter_addr').value='https://sub.id9.cc/';
		document.getElementById("merlinclash_subconverter_addr").readOnly = true;
		document.getElementById("merlinclash_subconverter_addr_cus").style.display = "none";
		document.getElementById("merlinclash_subconverter_addr").style.display = "";
		break;

		case "猫熊":
		document.getElementById('merlinclash_subconverter_addr').value='https://sub.maoxiongnet.com/';
		document.getElementById("merlinclash_subconverter_addr").readOnly = true;
		document.getElementById("merlinclash_subconverter_addr_cus").style.display = "none";
		document.getElementById("merlinclash_subconverter_addr").style.display = "";
		break;

		case "HEROKU":
		document.getElementById('merlinclash_subconverter_addr').value='https://subconverter.herokuapp.com/';
		document.getElementById("merlinclash_subconverter_addr").readOnly = true;
		document.getElementById("merlinclash_subconverter_addr_cus").style.display = "none";
		document.getElementById("merlinclash_subconverter_addr").style.display = "";
		break;

		case "自定义":
		if(db_merlinclash["merlinclash_subconverter_addr_cus"]){
			document.getElementById('merlinclash_subconverter_addr_cus').value = db_merlinclash["merlinclash_subconverter_addr_cus"];
		}else{
			document.getElementById('merlinclash_subconverter_addr_cus').value = 'https://sub.id9.cc/';

		}
		document.getElementById("merlinclash_subconverter_addr").style.display = "none";
		document.getElementById("merlinclash_subconverter_addr_cus").style.display = "";
		document.getElementById("merlinclash_subconverter_addr_cus").readOnly = false;
		break;
	}
}
function clear_yaml() {
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_clearyaml.sh", "params":[], "fields": ""};
	var yamlname=""
	intoQueue({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {
		}
	});
}
function get_dnsyaml(dns_tag) {
	var id = parseInt(Math.random() * 100000000);
	var dbus_post={};
	dbus_post["merlinclash_dnsedit_tag"] = db_merlinclash["merlinclash_dnsedit_tag"] = dns_tag;
	var postData = {"id": id, "method": "clash_getdnsyaml.sh", "params":[], "fields": dbus_post};
	intoQueue({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {
			dns_yaml_view(dns_tag);
		}
	});
}
function get_host(host_tag) {
	var id = parseInt(Math.random() * 100000000);
	var dbus_post={};
	dbus_post["merlinclash_hostsel"] = db_merlinclash["merlinclash_hostsel"] = host_tag;
	var postData = {"id": id, "method": "clash_gethost.sh", "params":[], "fields": dbus_post};
	intoQueue({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {
			host_view(host_tag);
		}
	});
}
//修改clash运行模式
function PATCH_MODE(mode_tag) {
	var id = parseInt(Math.random() * 100000000);
	var dbus_post={};
	dbus_post["merlinclash_clashmode"] = db_merlinclash["merlinclash_clashmode"] = mode_tag;
	var postData = {"id": id, "method": "clash_patchmode.sh", "params":[], "fields": dbus_post};
	intoQueue({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {

		}
	});
}
//修改自定规则模式显示
function CUSRULE_MODE(mode_tag) {
	if(mode_tag == "closed"){
		document.getElementById("merlinclash_cusrule_table").style.display="none"
		document.getElementById("merlinclash_cusrule_edit_content").style.display="none"

	}else if(mode_tag == "easy"){
		document.getElementById("merlinclash_cusrule_table").style.display=""
		document.getElementById("merlinclash_cusrule_edit_content").style.display="none"
	}else{
		document.getElementById("merlinclash_cusrule_table").style.display="none"
		document.getElementById("merlinclash_cusrule_edit_content").style.display=""
	}
	rule_tag = db_merlinclash["merlinclash_yamlsel"];
	if(init_cusrulecount == 0){
		var id = parseInt(Math.random() * 100000000);
		var dbus_post={};
		dbus_post["merlinclash_cusrule_plan"] = db_merlinclash["merlinclash_cusrule_plan"] = mode_tag;
		dbus_post["merlinclash_yamlsel"] = rule_tag;
		var postData = {"id": id, "method": "clash_getcusrule.sh", "params":[], "fields": dbus_post};
		intoQueue({
			type: "POST",
			cache:false,
			url: "/_api/",
			data: JSON.stringify(postData),
			dataType: "json",
			success: function(response) {
				cusrule_view(rule_tag);
			}
		});
	}else{
		cusrule_view(rule_tag);
	}
	init_cusrulecount = 1;

}
//自定订阅规则切换显示
function set_rulemode() {
		var id = parseInt(Math.random() * 100000000);
		var dbus_post={};
		if(E("merlinclash_customrule_cbox").checked){
			dbus_post["merlinclash_customrule_cbox"] = db_merlinclash["merlinclash_customrule_cbox"] = 1;
		}else{
			dbus_post["merlinclash_customrule_cbox"] = db_merlinclash["merlinclash_customrule_cbox"] = 0;
		}
		var postData = {"id": id, "method": "dummy_script.sh", "params":[], "fields": dbus_post};
		intoQueue({
			type: "POST",
			cache:false,
			url: "/_api/",
			data: JSON.stringify(postData),
			dataType: "json",
			success: function(response) {
				if(E("merlinclash_customrule_cbox").checked){
					document.getElementById("merlinclash_acl4ssrsel").style.display="none";
					document.getElementById("merlinclash_acl4ssrsel_cus").style.display="";
				}else{
					document.getElementById("merlinclash_acl4ssrsel").style.display="";
					document.getElementById("merlinclash_acl4ssrsel_cus").style.display="none";
				}
				document.getElementById("merlinclash_cdn_cbox").style.display="none";
				document.getElementById("merlinclash_cdn_cbox_span").style.display="none";
			}
		});
}
//获取dns-yaml
function dns_yaml_view(dns_tag) {
	intoQueue({
		url: '/_temp/dns_' + dns_tag + '.txt',
		type: 'GET',
		dataType: 'html',
		async: true,
		cache:false,
		success: function(response) {
			var retArea = E("merlinclash_dns_edit_content1");
			retArea.value = response;

		},
		error: function(xhr) {
			E("merlinclash_dns_edit_content1").value = "获取dns配置文件失败！";
		}
	});
}
//获取host-yaml
function host_view(host_tag) {
	intoQueue({
		url: '/_temp/' + host_tag + '.txt',
		type: 'GET',
		dataType: 'html',
		async: true,
		cache:false,
		success: function(response) {
			var retArea = E("merlinclash_host_content1");
			retArea.value = response;

		},
		error: function(xhr) {
			E("merlinclash_host_content1").value = "获取host配置文件失败！";
		}
	});
}
//获取rules-yaml
function cusrule_view(rule_tag) {
	intoQueue({
		url: '/_temp/' + rule_tag + '_rules.txt',
		type: 'GET',
		dataType: 'html',
		async: true,
		cache:false,
		success: function(response) {
			var retArea = E("merlinclash_cusrule_edit_content1");
			retArea.value = response;

		},
		error: function(xhr) {
			E("merlinclash_cusrule_edit_content1").value = "获取Rule规则文件失败！";
		}
	});
}
function ipsetyaml_get(){
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_getipsetproxy.sh", "params":[], "fields": ""};
	intoQueue({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {
			if(response.result == id){
				ipset_yaml_view();
				ipsetarround_yaml_view();
			}
		}
	});
}

//获取ipset-yaml
function ipset_yaml_view() {
	intoQueue({
		url: '/_temp/clash_ipsetproxy.txt',
		type: 'GET',
		dataType: 'html',
		async: true,
		cache:false,
		success: function(response) {
			var retArea = E("merlinclash_ipsetproxy_edit_content1");
			retArea.value = response;
		},
		error: function(xhr) {
			E("merlinclash_ipsetproxy_edit_content1").value = "未设置转发CLASH集！";
		}
	});
}
//获取ipset-yaml
function ipsetarround_yaml_view() {
	intoQueue({
		url: '/_temp/clash_ipsetproxyarround.txt',
		type: 'GET',
		dataType: 'html',
		async: true,
		cache:false,
		success: function(response) {
			var retArea = E("merlinclash_ipsetproxyarround_edit_content1");
			retArea.value = response;
		},
		error: function(xhr) {
			E("merlinclash_ipsetproxyarround_edit_content1").value = "未设置绕行CLASH集！";
		}
	});
}
//------------------------------------------本地上传clash二进制 开始------------------------------------//
function upload_clashbinary() {

	if(!$.trim($('#clashbinary').val())){
		alert("请先选择二进制文件");
		return false;
	}
	layer.confirm('<li>请确保二进制文件合法！仍要上传二进制吗？</li>', {
		shade: 0.8,
	}, function(index) {
		E('clashbinary_upload').style.display = "none";
		var uploadname = E("merlinclash_binary_type").value;
		var formData = new FormData();
		formData.append(uploadname, document.getElementById('clashbinary').files[0]);
		intoQueue({
			url: '/_upload',
			type: 'POST',
			cache: false,
			data: formData,
			processData: false,
			contentType: false,
			complete: function(res) {
				if (res.status == 200) {
					upload_binary(uploadname);
				}
			}
		});
		layer.close(index);
		return true;
	}, function(index) {
		layer.close(index);
		return false;
	});
}
function upload_binary(uploadname) {
	var dbus_post = {};
	action = dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = "12"
	dbus_post["merlinclash_binary_type"] = db_merlinclash["merlinclash_binary_type"] = E("merlinclash_binary_type").value;
	push_data("clash_local_binary_upload.sh", action,  dbus_post);
	E('clashbinary_upload').style.display = "block";
}
//------------------------------------------本地上传clash二进制 结束------------------------------------//
//------------------------------------------本地上传补丁 开始------------------------------------//
// function upload_clashpatch() {

// 	if(!$.trim($('#clashpatch').val())){
// 		alert("请先选择补丁包");
// 		return false;
// 	}
// 	layer.confirm('<li>请确保补丁文件合法！仍要上传安装补丁吗？</li>', {
// 		shade: 0.8,
// 	}, function(index) {
// 		var patchname = $("#clashpatch").val();
// 		patchname = patchname.split('\\');
// 		patchname = patchname[patchname.length - 1];
// 		var lastindex = patchname.lastIndexOf('.')
// 		patchlast = patchname.substring(lastindex)
// 		if (patchlast != ".gz") {
// 			alert('补丁包格式不正确！');
// 			return false;
// 		}
// 		E('clashpatch_upload').style.display = "none";
// 		var formData = new FormData();
// 		formData.append(patchname, document.getElementById('clashpatch').files[0]);
// 		intoQueue({
// 			url: '/_upload',
// 			type: 'POST',
// 			cache: false,
// 			data: formData,
// 			processData: false,
// 			contentType: false,
// 			complete: function(res) {
// 				if (res.status == 200) {
// 					upload_patch(patchname);
// 				}
// 			}
// 		});
// 		layer.close(index);
// 		return true;
// 	}, function(index) {
// 		layer.close(index);
// 		return false;
// 	});
// }
// function upload_patch(patchname) {
// 	var dbus_post = {};
// 	action = dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = "15"
// 	dbus_post["merlinclash_uploadpatchname"] = db_merlinclash["merlinclash_uploadpatchname"] = patchname;
// 	push_data("clash_local_patch_upload.sh", action,  dbus_post);
// 	E('clashpatch_upload').style.display = "block";
// }
//------------------------------------------本地上传补丁 结束------------------------------------//

//------------------------------------------本地上传配置 开始------------------------------------//
function upload_clashconfig() {
	var filename = $("#clashconfig").val();
	filename = filename.split('\\');
	filename = filename[filename.length - 1];
	var filelast = filename.split('.');
	filelast = filelast[filelast.length - 1];
	if (filename.length > 15) {
		alert(filename + '上传文件的文件名超过15个字符，请修改');
		return false;
	}
	if (filelast != "yaml") {
		alert('上传文件格式非法！只支持上传yaml后缀的配置文件');
		return false;
	}
	var reg = new RegExp("^[A-Za-z0-9]+$");
	//用.分割文件名
	var filenameCheck = filename.split('.');
	//大于2段说明文件名含"."直接报错，否则就用正则判断
	if (filenameCheck.length > 2 || !reg.test(filenameCheck[0]) ) {
		alert("上传文件格式非法！只能由字母和数字组成");
		return false;
	}
	E('clashconfig_info').style.display = "none";
	var formData = new FormData();

	formData.append(filename, document.getElementById('clashconfig').files[0]);

	intoQueue({
		url: '/_upload',
		type: 'POST',
		cache: false,
		data: formData,
		processData: false,
		contentType: false,
		complete: function(res) {
			if (res.status == 200) {
				upload_config(filename);
			}
		}
	});
}

//配置文件处理
function upload_config(filename) {
	var dbus_post = {};
	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = "3"
	dbus_post["merlinclash_uploadfilename"] = db_merlinclash["merlinclash_uploadfilename"] = filename;
	push_data("clash_config.sh", "upload",  dbus_post);
	E('clashconfig_info').style.display = "block";
	//20200713
	yaml_select();
}
//------------------------------------------本地上传配置 结束------------------------------------//
//------------------------------------------上传HOST 开始---------------------------------------//
function upload_clashhost() {
	var filename = $("#clashhost").val();
	filename = filename.split('\\');
	filename = filename[filename.length - 1];
	var filelast = filename.split('.');
	filelast = filelast[filelast.length - 1];
	if (filelast != "yaml") {
		alert('上传文件格式非法！只支持上传yaml后缀的hosts文件');
		return false;
	}
	E('clashhost_upload').style.display = "none";
	var formData = new FormData();

	//filename_tmp="hosts.yaml"
	formData.append(filename, document.getElementById('clashhost').files[0]);

	intoQueue({
		url: '/_upload',
		type: 'POST',
		cache: false,
		data: formData,
		processData: false,
		contentType: false,
		complete: function(res) {
			if (res.status == 200) {
				upload_host(filename);
			}
		}
	});
}
function upload_host(filename) {
	var dbus_post = {};
	action = dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = "22"
	dbus_post["merlinclash_uploadhost"] = db_merlinclash["merlinclash_uploadhost"] = filename;
	push_data("clash_local_host_upload.sh", action,  dbus_post);
	E('clashhost_upload').style.display = "block";
	//20210415
	host_select();
}
//------------------------------------------上传HOST 结束---------------------------------------//
function update_notice(int){
	if ( int == "1"){
		alert('无在线更新功能，请到频道下载新补丁');
		return false;
	}else if( int == "0"){
		alert('暂无新版本');
		return false;
	}else{
		alert('无在线更新功能，请到频道下载新版本');
		return false;
	}

}
function version_show() {
	if(!db_merlinclash["merlinclash_version_local"]) db_merlinclash["merlinclash_version_local"] = "0.0.0"
		$("#merlinclash_version_show").html("<a class='hintstyle'><i>当前版本：" + db_merlinclash['merlinclash_version_local'] + "</i></a>");
	$("#merlinclash_core_version").html("<span>clash：" + "Mihomo " + db_merlinclash['merlinclash_clash_version'] + " </span></div></td>");
}
function markdisplay(label) {
	var A = {};
	A = E(label).checked ? '1' : '0';
	if(A == "1"){
		document.getElementById("mark_value").style.display=""
	}else{
		document.getElementById("mark_value").style.display="none"
	}
}
var dbus_label_post = {};
function functioncheck(label,real_post) {
	if(real_post){
		var id = parseInt(Math.random() * 100000000);
		var postData = {"id": id, "method": "dummy_script.sh", "params":[], "fields": dbus_label_post};
		intoQueue({
			type: "POST",
			cache:false,
			url: "/_api/",
			data: JSON.stringify(postData),
			dataType: "json",
			error: function(xhr) {

			},
			success: function(response) {
				refreshpage();
			}
		});
	}else{
		if(label){
			dbus_label_post[label] = db_merlinclash[label] = E(label).checked ? '1' : '0';
		}
	}
}
function dnsfilechange() {
	var dbus_post = {};
	var dns_content = E("merlinclash_dns_edit_content1").value;
	var dns_base64 = "";
	if(dns_content != ""){
		if(dns_content.search(/^dns:/) >= 0){
			dns_base64 = Base64.encode(encodeURIComponent(dns_content));
			dbus_post["merlinclash_dns_edit_content1"] = db_merlinclash["merlinclash_dns_edit_content1"] = dns_base64;
		}else{
			alert("dns区域内容有误，提交dns配置必须以dns:开头");
			return false;
		}
	}else{
		alert("dns区域内容不能为空！！！");
		return false;
	}
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_dnsfilechange.sh", "params":[], "fields": dbus_post};
	intoQueue({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		error: function(xhr) {

		},
		success: function(response) {
			refreshpage();
		}
	});
}
//ip集区域文本保存
function ipsetchange() {
	var dbus_post = {};
	var ipset_content = E("merlinclash_ipsetproxy_edit_content1").value;
	if(hasChinese(ipset_content)){
		alert("修改提交失败，不能含有中文");
		return false;
	}
	var ipset_base64 = "";
	if(ipset_content != ""){
		ipset_base64 = Base64.encode(ipset_content);
		dbus_post["merlinclash_ipsetproxy_edit_content1"] = db_merlinclash["merlinclash_ipsetproxy_edit_content1"] = ipset_base64;
	}else{
		dbus_post["merlinclash_ipsetproxy_edit_content1"] = db_merlinclash["merlinclash_ipsetproxy_edit_content1"] = " ";
	}
	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = "36"
	push_data("clash_ipsetproxychange.sh", "ipsetproxy",  dbus_post);
}
//ip集区域文本保存
function ipsetarroundchange() {
	var dbus_post = {};
	var ipseta_content = E("merlinclash_ipsetproxyarround_edit_content1").value;
	if(hasChinese(ipseta_content)){
		alert("修改提交失败，不能含有中文");
		return false;
	}
	var ipseta_base64 = "";
	if(ipseta_content != ""){
		ipseta_base64 = Base64.encode(ipseta_content);
		dbus_post["merlinclash_ipsetproxyarround_edit_content1"] = db_merlinclash["merlinclash_ipsetproxyarround_edit_content1"] = ipseta_base64;
	}else{
		dbus_post["merlinclash_ipsetproxyarround_edit_content1"] = db_merlinclash["merlinclash_ipsetproxyarround_edit_content1"] = " ";
	}
	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = "37"
	push_data("clash_ipsetproxyarroundchange.sh", "ipsetproxy",  dbus_post);
}
// 判断字符串是否包含中文
function hasChinese(str) {
	return /[\u4E00-\u9FA5]+/g.test(str)
}

//host区域文本保存
function hostchange(){
	//采取分段保存
	var dbus_post = {};
	var str="";
	var n = 5000;
	var i = 0;
	var host_content = E("merlinclash_host_content1").value;
	if(host_content != ""){
		if(host_content.search(/^hosts:/) >= 0){
			str = Base64.encode(encodeURIComponent(host_content));
			for (l = str.length; i < l/n; i++) {
				var a = str.slice(n*i, n*(i+1));
				dbus_post["merlinclash_host_content1_" + i] = db_merlinclash["merlinclash_host_content1_" + i] = a;
			}
			dbus_post["merlinclash_host_content1_count"] = db_merlinclash["merlinclash_host_content1_count"] = i;
		}else{
			alert("host区域内容有误，提交host配置必须以hosts:开头");
			return false;
		}
	}else{
		dbus_post["merlinclash_host_content1_0"] = db_merlinclash["merlinclash_host_content1_0"] = " ";
		dbus_post["merlinclash_host_content1_count"] = db_merlinclash["merlinclash_host_content1_count"] = 1;
	}
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_hostchange.sh", "params":[], "fields": dbus_post};
	intoQueue({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		error: function(xhr) {

		},
		success: function(response) {
			refreshpage();
		}
	});
}
//自定规则专业模式保存
function cusrulechange(){
	//采取分段保存
	var dbus_post = {};
	var str="";
	var n = 5000;
	var i = 0;
	var cusrule_content = E("merlinclash_cusrule_edit_content1").value;
	if(cusrule_content != ""){
		if(cusrule_content.search(/^rules:/) >= 0){
			str = Base64.encode(encodeURIComponent(cusrule_content));
			console.log(str);
			for (l = str.length; i < l/n; i++) {
				var a = str.slice(n*i, n*(i+1));
				dbus_post["merlinclash_cusrule_edit_content1_" + i] = db_merlinclash["merlinclash_cusrule_edit_content1_" + i] = a;
			}
			dbus_post["merlinclash_cusrule_edit_content1_count"] = db_merlinclash["merlinclash_cusrule_edit_content1_count"] = i;
		}else{
			alert("自定规则区域内容有误，提交自定规则必须以rules:开头");
			return false;
		}
	}else{
		dbus_post["merlinclash_cusrule_edit_content1_0"] = db_merlinclash["merlinclash_cusrule_edit_content1_0"] = " ";
		dbus_post["merlinclash_cusrule_edit_content1_count"] = db_merlinclash["merlinclash_cusrule_edit_content1_count"] = 1;
	}
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_cusrulechange.sh", "params":[], "fields": dbus_post};
	intoQueue({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		error: function(xhr) {

		},
		success: function(response) {
			refreshpage();
		}
	});
}

//定时订阅
function regular_subscribe_save() {
	var dbus_post = {};
	var id = parseInt(Math.random() * 100000000);
	var subscribeplansel = document.getElementsByName("subscribeplan").innerHTML = getradioval(9);
	dbus_post["merlinclash_subscribeplan"]	= db_merlinclash["merlinclash_subscribeplan"] = subscribeplansel;
	dbus_post["merlinclash_select_regular_subscribe"]	= db_merlinclash["merlinclash_select_regular_subscribe"] = E("merlinclash_select_regular_subscribe").value;
	dbus_post["merlinclash_select_regular_day"]	= db_merlinclash["merlinclash_select_regular_day"] = E("merlinclash_select_regular_day").value;
	dbus_post["merlinclash_select_regular_week"] = db_merlinclash["merlinclash_select_regular_week"] = E("merlinclash_select_regular_week").value;
	dbus_post["merlinclash_select_regular_hour"] = db_merlinclash["merlinclash_select_regular_hour"] = E("merlinclash_select_regular_hour").value;
	dbus_post["merlinclash_select_regular_minute"] = db_merlinclash["merlinclash_select_regular_minute"] = E("merlinclash_select_regular_minute").value;
	dbus_post["merlinclash_select_regular_minute_2"] = db_merlinclash["merlinclash_select_regular_minute_2"] = E("merlinclash_select_regular_minute_2").value;
	var postData = {"id": id, "method": "clash_regular_subscribe.sh", "params":[], "fields": dbus_post};
	intoQueue({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		error: function(xhr) {

		},
		success: function(response) {
			refreshpage();
		}
	});
}

//开启mixport开关
function mixport_save() {
	var dbus_post = {};
	var id = parseInt(Math.random() * 100000000);
	if(E("merlinclash_mixport_enable").checked == false){
		layer.confirm('<li>请确保已经成功开启了路由器防火墙！！！</li><li>否则端口可能暴露在公网环境下，被偷取代理流量！！！</li>', {
			shade: 0.8,
			closeBtn: 0,
			title: "确定开启http/socks代理端口吗？",
			btn: ["开启http/socks代理端口","取消"]
		}, function(index) {
			dbus_post["merlinclash_mixport_enable"] = db_merlinclash["merlinclash_mixport_enable"] = "1"
			push_data("dummy_script.sh", "", dbus_post, "2");
			layer.close(index);
			return true;
		}, function(index) {
			E("merlinclash_mixport_enable").checked = false;
			layer.close(index);
			return false;
		});
	}else{
		dbus_post["merlinclash_mixport_enable"] = db_merlinclash["merlinclash_mixport_enable"] = "0"
		push_data("dummy_script.sh", "", dbus_post, "2");
	}

}

//保存UA
function useragent_save() {
	var dbus_post = {};
	var id = parseInt(Math.random() * 100000000);
	var uacode = Base64.encode(E("merlinclash_useragent").value);
	dbus_post["merlinclash_useragent"] = db_merlinclash["merlinclash_useragent"] = uacode;
	push_data("dummy_script.sh", "", dbus_post, "2");
	alert("UserAgent修改成功！！！您可以重新尝试订阅了~\r如果订阅失败,请咨询你的机场，修改成加适合的UserAgent！");
}
//定时重启
function clash_restart_save() {
	var dbus_post = {};
	var id = parseInt(Math.random() * 100000000);
	dbus_post["merlinclash_select_clash_restart"]	= db_merlinclash["merlinclash_select_clash_restart"] = E("merlinclash_select_clash_restart").value;
	dbus_post["merlinclash_select_clash_restart_day"]	= db_merlinclash["merlinclash_select_clash_restart_day"] = E("merlinclash_select_clash_restart_day").value;
	dbus_post["merlinclash_select_clash_restart_week"] = db_merlinclash["merlinclash_select_clash_restart_week"] = E("merlinclash_select_clash_restart_week").value;
	dbus_post["merlinclash_select_clash_restart_hour"] = db_merlinclash["merlinclash_select_clash_restart_hour"] = E("merlinclash_select_clash_restart_hour").value;
	dbus_post["merlinclash_select_clash_restart_minute"] = db_merlinclash["merlinclash_select_clash_restart_minute"] = E("merlinclash_select_clash_restart_minute").value;
	dbus_post["merlinclash_select_clash_restart_minute_2"] = db_merlinclash["merlinclash_select_clash_restart_minute_2"] = E("merlinclash_select_clash_restart_minute_2").value;
	var postData = {"id": id, "method": "clash_restart_regularly.sh", "params":[], "fields": dbus_post};
	intoQueue({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		error: function(xhr) {

		},
		success: function(response) {
			refreshpage();
		}
	});
}
//导出日志
function outputlog(){
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_outputlog.sh", "params":[], "fields": ""};
	intoQueue({
		type: "POST",
		async: true,
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {
			if(response.result == id){
				var downloadA = document.createElement('a');
				var josnData = {};
				var a = "http://"+window.location.hostname+"/_temp/"+"clash_run.log"
				var blob = new Blob([JSON.stringify(josnData)],{type : 'application/json'});
				downloadA.href = a;
				downloadA.download = "clash_run.log";
				downloadA.click();
				window.URL.revokeObjectURL(downloadA.href);
			}
		}
	});
}
//提交看门狗设置
function clash_watchdog_save() {
	var dbus_post = {};
	var id = parseInt(Math.random() * 100000000);
	dbus_post["merlinclash_watchdog"]	= db_merlinclash["merlinclash_watchdog"] = E("merlinclash_watchdog").checked ? '1' : '0';
	dbus_post["merlinclash_watchdog_delay_time"]	= db_merlinclash["merlinclash_watchdog_delay_time"] = E("merlinclash_watchdog_delay_time").value;
	var postData = {"id": id, "method": "clash_watchdog_enable.sh", "params":[], "fields": dbus_post};
	intoQueue({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		error: function(xhr) {

		},
		success: function(response) {
			refreshpage();
		}
	});
}

function savesniffer(){
	//采取分段保存
	var dbus_post = {};
	var str="";
	var n = 5000;
	var i = 0;
	var sr_content = E("snifferrulestxt").value;
	if(sr_content != ""){
		str = Base64.encode(encodeURIComponent(sr_content));
		for (l = str.length; i < l/n; i++) {
			var a = str.slice(n*i, n*(i+1));
			dbus_post["merlinclash_sniffer_content_" + i] = db_merlinclash["merlinclash_sniffer_content_" + i] = a;
		}
		dbus_post["merlinclash_sniffer_content_count"] = db_merlinclash["merlinclash_sniffer_content_count"] = i;
	}else{
		dbus_post["merlinclash_sniffer_content_0"] = db_merlinclash["merlinclash_sniffer_content_0"] = " ";
		dbus_post["merlinclash_sniffer_content_count"] = db_merlinclash["merlinclash_sniffer_content_count"] = 1;
	}
	//post data
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_snifferchange.sh", "params":[], "fields": dbus_post};
	intoQueue({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		error: function(xhr) {

		},
		success: function(response) {
			refreshpage();
		}
	});
}

function geoip_update(action){
	var dbus_post = {};
	var date = new Date();
	    var seperator1 = "-";
	    var seperator2 = ":";
	    var month = date.getMonth() + 1;
	    var strDate = date.getDate();
	    if (month >= 1 && month <= 9) {
		        month = "0" + month;
	    }
	    if (strDate >= 0 && strDate <= 9) {
		        strDate = "0" + strDate;
	    }
	    var currentdate = date.getFullYear() + seperator1 + month + seperator1 + strDate
	            + " " + date.getHours() + seperator2 + date.getMinutes()
	            + seperator2 + date.getSeconds();
	layer.confirm('<li>你确定要更新GeoIP数据库吗？</li>', {
		shade: 0.8,
	}, function(index) {
		$("#log_content3").attr("rows", "20");
		dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action;
		dbus_post["merlinclash_updata_date"] = db_merlinclash["merlinclash_updata_date"] = currentdate;
		dbus_post["merlinclash_geoip_type"] = db_merlinclash["merlinclash_geoip_type"] = E("merlinclash_geoip_type").value;
		push_data("clash_update_ipdb.sh", action, dbus_post);
		E("geoip_updata_date").innerHTML = "<span style='color: gold'>上次更新时间："+db_merlinclash["merlinclash_updata_date"]+"</span>";
		layer.close(index);
		return true;

	}, function(index) {
		layer.close(index);
		return false;
	});
}
function chnroute_update(action){
	var dbus_post = {};
	var date = new Date();
	    var seperator1 = "-";
	    var seperator2 = ":";
	    var month = date.getMonth() + 1;
	    var strDate = date.getDate();
	    if (month >= 1 && month <= 9) {
		        month = "0" + month;
	    }
	    if (strDate >= 0 && strDate <= 9) {
		        strDate = "0" + strDate;
	    }
	    var currentdate = date.getFullYear() + seperator1 + month + seperator1 + strDate
	            + " " + date.getHours() + seperator2 + date.getMinutes()
	            + seperator2 + date.getSeconds();
	layer.confirm('<li>你确定要更新大陆白名单规则吗？</li>', {
		shade: 0.8,
	}, function(index) {
		$("#log_content3").attr("rows", "20");
		dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action;
		dbus_post["merlinclash_chnrouteupdate_date"] = db_merlinclash["merlinclash_chnrouteupdate_date"] = currentdate;
		push_data("clash_update_chnroute.sh", action, dbus_post);
		E("chnroute_updata_date").innerHTML = "<span style='color: gold'>上次更新时间："+db_merlinclash["merlinclash_chnrouteupdate_date"]+"</span>";
		layer.close(index);
		return true;

	}, function(index) {
		layer.close(index);
		return false;
	});
}
function sc_update(action) {
	var dbus_post = {};
	layer.confirm('<li>你确定要更新subconverter规则文件吗？</li>', {
		shade: 0.8,
	}, function(index) {
		$("#log_content3").attr("rows", "20");
		dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action;
		push_data("clash_update_sc.sh", action, dbus_post);
		layer.close(index);
		return true;

	}, function(index) {
		layer.close(index);
		return false;
	});
}
function doalert(id){
	if(this.checked) {
		alert('checked');
	}else{
		alert('unchecked');
	}
}
// function clash_getversion(action) {
// 	var dbus_post = {};
// 	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action;
// 	push_data("clash_get_binary_history.sh", action, dbus_post);
// }
// function clash_replace(action) {
// 	if(!$.trim($('#merlinclash_clashbinarysel').val())){
// 		alert("请选择二进制版本");
// 		return false;
// 	}
// 	var dbus_post = {};
// 	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action;
// 	dbus_post["merlinclash_clashbinarysel"] = db_merlinclash["merlinclash_clashbinarysel"] = E("merlinclash_clashbinarysel").value;
// 	push_data("clash_get_binary_history.sh", action, dbus_post);
// }

//----------------下拉框获取host文件名BEGIN--------------------------
function host_select(){
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_gethostsel.sh", "params":[], "fields": ""};
	intoQueue({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {
			if(response.result == id){
				host_select_get();
			}
		}
	});
}

function host_select_get() {

	intoQueue({
		url: '/_temp/hosts.txt',
		type: 'GET',
		cache:false,
		dataType: 'text',
		success: function(response) {
			//按换行符切割
			var arr = response.split("\n");
			Myhostselect(arr);
		}
	});
}
var hostcounts;
hostcounts=0;
function Myhostselect(arr){
	var i;
	hostcounts=arr.length;
	var hostlist = arr;  
	for(i=0;i<hostlist.length-1;i++){
		var a=hostlist[i];
		if(a == db_merlinclash["merlinclash_hostsel"]){//如果是用户选择的，则变成被选中状态
			$("#merlinclash_hostsel").append("<option value=" + a + " selected>" + a + "</option>")
		}else{
			$("#merlinclash_hostsel").append("<option value=" + a + ">" + a + "</option>");
		}
	}
}
//----------------下拉框获取host文件名 END --------------------------
//----------------下拉框获取配置文件名BEGIN--------------------------
function yaml_select(){
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_getyamls.sh", "params":[], "fields": ""};
	intoQueue({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {
			if(response.result == id){
				yaml_select_get();
				yamlcus_select_get();
				yamlcuslist_select_get();
			}
		}
	});
}

function yaml_select_get() {
	intoQueue({
		url: '/_temp/yamls.txt',
		type: 'GET',
		cache:false,
		dataType: 'text',
		success: function(response) {
			//按换行符切割
			var arr = response.split("\n");
			Myselect(arr);
		}
	});
}
var counts;
counts=0;
function Myselect(arr){
	var i;
	counts=arr.length;
	var yamllist = arr;
	$("#merlinclash_yamlsel").append("<option value=''>--请选择--</option>");
	$("#merlinclash_delyamlsel").append("<option value=''>--请选择--</option>");

	for(i=0;i<yamllist.length-1;i++){
		var a=yamllist[i];
		//$("#merlinclash_yamlsel").append("<option value='"+a+"' >"+a+"</option>");
		if(a == db_merlinclash["merlinclash_yamlsel"]){//如果是用户选择的，则变成被选中状态
			$("#merlinclash_yamlsel").append("<option value=" + a + " selected>" + a + "</option>")
		}else{
			$("#merlinclash_yamlsel").append("<option value=" + a + ">" + a + "</option>");
		}
		$("#merlinclash_delyamlsel").append("<option value=" + a + ">" + a + "</option>");
	}
}
function yamlcus_select_get() {
	intoQueue({
		url: '/_temp/yamlscus.txt',
		type: 'GET',
		cache:false,
		dataType: 'text',
		success: function(response) {
			//按换行符切割
			var arr = response.split("\n");
			Mycusselect(arr);
		}
	});
}
var countscus;
countscus=0;
function Mycusselect(arr){
	var i;
	countscus=arr.length;
	var yamlcuslist = arr;  
	$("#merlinclash_delinisel").append("<option value=''>--请选择--</option>");
	for(i=0;i<yamlcuslist.length-1;i++){
		var a=yamlcuslist[i];
		$("#merlinclash_acl4ssrsel_cus").append("<option value='"+a+"' >"+a+"</option>");
		$("#merlinclash_delinisel").append("<option value='"+a+"' >"+a+"</option>");
	}
}
function yamlcuslist_select_get() {

	intoQueue({
		url: '/_temp/yamlscuslist.txt',
		type: 'GET',
		cache:false,
		dataType: 'text',
		success: function(response) {
			//按换行符切割
			var arr = response.split("\n");
			Mycuslistselect(arr);
		}
	});
}
var countscuslist;
countscuslist=0;
function Mycuslistselect(arr){
	var i;
	countscuslist=arr.length;
	var yamlcuslist = arr;  
	$("#merlinclash_dellistsel").append("<option value=''>--请选择--</option>");
	for(i=0;i<yamlcuslist.length-1;i++){
		var a=yamlcuslist[i];
		$("#merlinclash_dellistsel").append("<option value='"+a+"' >"+a+"</option>");
	}
}
//----------------下拉框获取配置文件名END--------------------------
//----------------下拉框获取clash版本号BEGIN--------------------------
// function clashbinary_select(){
// 	var id = parseInt(Math.random() * 100000000);
// 	var postData = {"id": id, "method": "clash_getclashbinary.sh", "params":[], "fields": ""};
// 	intoQueue({
// 		type: "POST",
// 		cache:false,
// 		url: "/_api/",
// 		data: JSON.stringify(postData),
// 		dataType: "json",
// 		success: function(response) {
// 			if(response.result == id){
// 				clashbinary_select_get();

// 			}
// 		}
// 	});
// }

// function clashbinary_select_get() {

// 	intoQueue({
// 		url: '/_temp/clash_binary_history.txt',
// 		type: 'GET',
// 		cache:false,
// 		dataType: 'text',
// 		success: function(response) {
// 			//按换行符切割
// 			var arr = response.split("\n");
// 			Myclashbinary(arr);
// 		}
// 	});
// }
// var binarys;
// binarys=0;
// function Myclashbinary(arr){
// 	var k;
// 	binarys=arr.length;
// 	var binarylist = arr;  
// 	$("#merlinclash_clashbinarysel").append("<option value=''>---------请选择---------</option>");
// 	for(k=0;k<binarylist.length;k++){
// 		var a=binarylist[k];
// 		$("#merlinclash_clashbinarysel").append("<option value='"+a+"' >"+a+"</option>");
// 	}
// }
//----------------下拉框获取clash版本号END--------------------------
//----------------------------proxy-group 下拉框部分代码BEGIN-------------------------//
function proxygroup_select(){
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_getproxygroup.sh", "params":[], "fields": ""};
	intoQueue({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {
			if(response.result == id){
				setTimeout("proxygroup_select_get();", 300);
				setTimeout("proxytype_select_get();", 300);
			}
		}
	});
}
function proxygroup_select_get() {
	intoQueue({
		url: '/_temp/proxygroups.txt',
		type: 'GET',
		cache:false,
		dataType: 'text',
		success: function(response) {
			//按换行符切割
			var arr = response.split("\n");
			Mypgselect(arr);
		}
	});
}
var pgcounts;
pgcounts=0;
function Mypgselect(arr){
	var i;
	pgcounts=arr.length;
	var pglist = arr;  
	$("#merlinclash_acl_lianjie").append("<option value=''>--请选择--</option>");
	for(i=0;i<pglist.length-1;i++){
		var a=pglist[i];
		$("#merlinclash_acl_lianjie").append("<option value='"+a+"' >"+a+"</option>");
	}
}
function proxytype_select_get() {
	intoQueue({
		url: '/_temp/proxytype.txt',
		type: 'GET',
		cache:false,
		dataType: 'text',
		success: function(response) {
			//按换行符切割
			var arr = response.split("\n");
			Myptselect(arr);
		}
	});
}
var ptcounts;
ptcounts=0;
function Myptselect(arr){
	var i;
	ptcounts=arr.length;
	var ptlist = arr;  
	$("#merlinclash_acl_type").append("<option value=''>--请选择--</option>");
	for(i=0;i<ptlist.length-1;i++){
		var a=ptlist[i];
		$("#merlinclash_acl_type").append("<option value='"+a+"' >"+a+"</option>");
	}
}
//----------------------------proxy-group下拉框部分代码END--------------------------//

//----------------------------自定规则代码部分BEGIN--------------------------------------//
function refresh_acl_table(q) {
	$.ajax({
		type: "GET",
		url: "/_api/merlinclash_acl",
		dataType: "json",
		async: false,
		success: function(data) {
			db_acl = data.result[0];
			refresh_acl_html();

		//write dynamic table value
		for (var i = 1; i < acl_node_max + 1; i++) {
			if (typeof db_acl["merlinclash_acl_type_" + i] == "undefined") {
				continue;
			}
			$('#merlinclash_acl_type_' + i).val(db_acl["merlinclash_acl_type_" + i]);
			$('#merlinclash_acl_content_' + i).val(decodeURIComponent(Base64.decode(db_acl["merlinclash_acl_content_" + i])));
			$('#merlinclash_acl_lianjie_' + i).val(db_acl["merlinclash_acl_lianjie_" + i]);
			$('#merlinclash_acl_protocol_' + i).val(db_acl["merlinclash_acl_protocol_" + i]);

		}
		//after table generated and value filled, set default value for first line_image1
		$('#merlinclash_acl_protocol').val("none");
	}
});
}
function addTr() {
	if(!$.trim($('#merlinclash_acl_type').val())){
		alert("类型不能为空！");
		return false;
	}
	if(!$.trim($('#merlinclash_acl_content').val())){
		alert("内容不能为空！");
		return false;
	}
	if(!$.trim($('#merlinclash_acl_lianjie').val())){
		alert("连接方式不能为空！");
		return false;
	}
	var acls = {};
	var p = "merlinclash_acl";
	acl_node_max += 1;
	var params = ["type", "content", "lianjie", "protocol"];
	for (var i = 0; i < params.length; i++) {
		acls[p + "_" + params[i] + "_" + acl_node_max] = Base64.encode(encodeURIComponent($('#' + p + "_" + params[i]).val()));
	}
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_saveacls.sh", "params":["save"], "fields": acls};
	intoQueue({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		error: function(xhr) {
			console.log("error in posting config of table");
		},
		success: function(response) {
			refresh_acl_table();
			proxygroup_select_get();
			proxytype_select_get();
			//E("merlinclash_acl_content").value = ""
			//E("merlinclash_acl_lianjie").value = ""
			$('#merlinclash_acl_protocol').val("none");
		}
	});
	aclid = 0;
}
function delTr(o) {
	var id = $(o).attr("id");
	var ids = id.split("_");
	var p = "merlinclash_acl";
	id = ids[ids.length - 1];
	var acls = {};
	var params = ["type", "content", "lianjie", "protocol"];
	for (var i = 0; i < params.length; i++) {
		db_merlinclash[p + "_" + params[i] + "_" + id] = acls[p + "_" + params[i] + "_" + id] = "";
	}
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_saveacls.sh", "params":["del"], "fields": acls};

	intoQueue({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {
			proxygroup_select_get();
			proxytype_select_get();
			refresh_acl_table();

		}
	});
}
//自定规则
function refresh_acl_html() {
	acl_confs = getACLConfigs();
	var n = 0;
	for (var i in acl_confs) {
		n++;
	}
	var code = '';
	code += '<div id="merlinclash_cusrule_table">'
	// acl table th
	code += '<table width="750px" border="0" align="center" cellpadding="4" cellspacing="0" class="FormTable_table acl_lists" style="margin:-1px 0px 0px 0px;">'
	code += '<tr>'
	code += '<th width="20%" style="text-align: center; vertical-align: middle;"><a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(2)">类型</a></th>'
	code += '<th width="30%" style="text-align: center; vertical-align: middle;"><a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(3)">内容</a></th>'
	code += '<th width="20%" style="text-align: center; vertical-align: middle;"><a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(4)">连接方式</a></th>'
	// code += '<th width="20%" style="text-align: center; vertical-align: middle;"><a class="hintstyle" href="javascript:void(0);" >协议</a></th>'
	code += '<th width="8%">操作</th>'
	code += '</tr>'
	code += '</table>'
	// acl table input area
	code += '<table id="ACL_table" width="750px" border="0" align="center" cellpadding="4" cellspacing="0" class="list_table acl_lists" style="margin:-1px 0px 0px 0px;">'
	code += '<tr>'
	//类型
	code += '<td width="20%">'
	code += '<select id="merlinclash_acl_type" style="width:120px;margin:0px 0px 0px 2px;text-align:center;text-align-last:center;padding-left: 12px;" class="input_option">'
	//		code += '<option value="SRC-IP-CIDR">SRC-IP-CIDR</option>'
	//		code += '<option value="IP-CIDR">IP-CIDR</option>'
	//		code += '<option value="DOMAIN-SUFFIX">DOMAIN-SUFFIX</option>'
	//		code += '<option value="DOMAIN">DOMAIN</option>'
	//		code += '<option value="DOMAIN-KEYWORD">DOMAIN-KEYWORD</option>'
	//		code += '<option value="DST-PORT">DST-PORT</option>'
	//		code += '<option value="SRC-PORT">SRC-PORT</option>'
	//		code += '<option value="SCRIPT">SCRIPT</option>'
	code += '</select>'
	code += '</td>'
	//内容
	code += '<td width="30%">'
	code += '<input type="text" id="merlinclash_acl_content" class="input_15_table" maxlength="9999" style="width:200px;text-align:center" placeholder="" />'
	code += '</td>'
	//连接
	code += '<td width="20%">'
	code += '<select id="merlinclash_acl_lianjie" style="width:120px;margin:0px 0px 0px 2px;text-align:center;text-align-last:center;padding-left: 12px;" class="input_option">'
	code += '</select>'
	code += '</td>'
	// 协议
			// code += '<td width="20%">'
			// code += '<select id="merlinclash_acl_protocol" style="width:140px;margin:0px 0px 0px 2px;text-align:center;text-align-last:center;padding-left: 12px;" class="input_option">'
			// code += '<option value="none">无设置</option>'
			// code += '<option value="tcp">tcp</option>'
			// code += '<option value="udp">udp</option>'
	//		code += '<option value="DOMAIN">DOMAIN</option>'
	//		code += '<option value="DOMAIN-KEYWORD">DOMAIN-KEYWORD</option>'
	//		code += '<option value="DST-PORT">DST-PORT</option>'
	//		code += '<option value="SRC-PORT">SRC-PORT</option>'
	//		code += '<option value="SCRIPT">SCRIPT</option>'
			// code += '</select>'
			// code += '</td>'
	// add/delete 按钮
	code += '<td width="8%">'
	code += '<input style="margin-left: 6px;margin: -2px 0px -4px -2px;" type="button" class="add_btn" onclick="addTr()" value="" />'
	code += '</td>'
	code += '</tr>'
	// acl table rule area
	for (var field in acl_confs) {
		var ac = acl_confs[field];
		code += '<tr id="acl_tr_' + ac["acl_node"] + '">';
		code += '<td width="20%" id="merlinclash_acl_type_' +ac["acl_node"] + '">' + ac["type"] + '</td>';
		code += '<td width="40%">';
		code += '<input type="text" id="merlinclash_acl_content_' +ac["acl_node"] + '" class="input_option_2" maxlength="9999" placeholder="" />';
		code += '</td>';
		code += '<td width="20%" id="merlinclash_acl_lianjie_' +ac["acl_node"] + '">' + ac["lianjie"] + '</td>';
			// code += '<td width="10%" id="merlinclash_acl_protocol_' +ac["acl_node"] + '">' + ac["protocol"] + '</td>';
			code += '<td width="10%">';
			code += '<input style="margin: -2px 0px -4px -2px;" id="acl_node_' + ac["acl_node"] + '" class="remove_btn" type="button" onclick="delTr(this);" value="">'
			code += '</td>';
			code += '</tr>';
		}
		code += '</table>';
		code += '</div>'
		$(".acl_lists").remove();
		$('#merlinclash_acl_table').after(code);

	}
	function getACLConfigs() {
		var dict = {};
		for (var field in db_acl) {
			names = field.split("_");
			dict[names[names.length - 1]] = 'ok';
		}
		acl_confs = {};
		var p = "merlinclash_acl";
		var params = ["type", "content", "lianjie", "protocol"];
		for (var field in dict) {
			var obj = {};
			for (var i = 0; i < params.length; i++) {
				var ofield = p + "_" + params[i] + "_" + field;
				if (typeof db_acl[ofield] == "undefined") {
					obj = null;
					break;
				}
				obj[params[i]] = decodeURIComponent(Base64.decode(db_acl[ofield]));

			}
			if (obj != null) {
				var node_a = parseInt(field);
				if (node_a > acl_node_max) {
					acl_node_max = node_a;
				}
				obj["acl_node"] = field;
				acl_confs[field] = obj;
			}
		}
		return acl_confs;
	}
//----------------------------自定规则代码部分END--------------------------------------//
//----------------------------访问控制部分BEGIN--------------------------------//
function getnoKPACLConfigs() {
	var dict = {};
	for (var field in db_nokpacl) {
		names = field.split("_");
		dict[names[names.length - 1]] = 'ok';
	}
	nokpacl_confs = {};
	var p = "merlinclash_nokpacl";
	var params = ["ip", "mac", "port", "mode"];
	for (var field in dict) {
		var obj = {};
		if (typeof db_nokpacl[p + "_name_" + field] == "undefined") {
			obj["name"] = db_nokpacl[p + "_ip_" + field];
		} else {
			obj["name"] = db_nokpacl[p + "_name_" + field];
		}
		for (var i = 0; i < params.length; i++) {
			var ofield = p + "_" + params[i] + "_" + field;
			if (typeof db_nokpacl[ofield] == "undefined") {
				obj = null;
				break;
			}
			obj[params[i]] = db_nokpacl[ofield];
		}
		if (obj != null) {
			var node_a = parseInt(field);
			if (node_a > nokpacl_node_max) {
				nokpacl_node_max = node_a;
			}
			obj["nokpacl_node"] = field;
			nokpacl_confs[field] = obj;
		}
	}
	return nokpacl_confs;
}
function addnokpaclTr() {
	if(!$.trim($('#merlinclash_nokpacl_ip').val())){
		alert("主机IP地址不能为空！");
		return false;
	}
	if(!$.trim($('#merlinclash_nokpacl_name').val())){
		alert("主机别名不能为空！");
		return false;
	}
	var nokpacls = {};
	var p = "merlinclash_nokpacl";
	nokpacl_node_max += 1;
	var params = ["ip", "mac", "name", "port", "mode"];
	for (var i = 0; i < params.length; i++) {
		nokpacls[p + "_" + params[i] + "_" + nokpacl_node_max] = $('#' + p + "_" + params[i]).val();
	}
	if(nokpacls["merlinclash_nokpacl_mac_" + nokpacl_node_max] ==""){
		nokpacls["merlinclash_nokpacl_mac_" + nokpacl_node_max] = " "
	}
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "dummy_script.sh", "params":[], "fields": nokpacls};
	intoQueue({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		error: function(xhr) {
			console.log("error in posting config of table");
		},
		success: function(response) {
			refresh_nokpacl_table();
			E("merlinclash_nokpacl_name").value = ""
			E("merlinclash_nokpacl_ip").value = ""
			E("merlinclash_nokpacl_mac").value = ""
		}
	});
	nokpaclid = 0;
}
function delnokpaclTr(o) {
	var id = $(o).attr("id");
	var ids = id.split("_");
	var p = "merlinclash_nokpacl";
	id = ids[ids.length - 1];
	var nokpacls = {};
	var params = ["ip", "mac", "name", "port", "mode"];
	for (var i = 0; i < params.length; i++) {
		db_merlinclash[p + "_" + params[i] + "_" + id] = nokpacls[p + "_" + params[i] + "_" + id] = "";
	}
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "dummy_script.sh", "params":[], "fields": nokpacls};
	intoQueue({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {
			refresh_nokpacl_table();
		}
	});
}
function refresh_nokpacl_table(q) {
	intoQueue({
		type: "GET",
		url: "/_api/merlinclash_nokpacl",
		dataType: "json",
		async: false,
		success: function(data) {
			db_nokpacl = data.result[0];
			refresh_nokpacl_html();
			//write default rule port
			//console.log(db_nokpacl["merlinclash_nokpacl_default_port"]);
			if (typeof db_nokpacl["merlinclash_nokpacl_default_port"] != "undefined") {
				$('#merlinclash_nokpacl_default_port').val(db_nokpacl["merlinclash_nokpacl_default_port"]);
			} else {
				//console.log("进来这里");
				$('#merlinclash_nokpacl_default_port').val("all");
			}
			//write dynamic table value
			for (var i = 1; i < nokpacl_node_max + 1; i++) {
				$('#merlinclash_nokpacl_mode_' + i).val(db_nokpacl["merlinclash_nokpacl_mode_" + i]);
				$('#merlinclash_nokpacl_port_' + i).val(db_nokpacl["merlinclash_nokpacl_port_" + i]);
				$('#merlinclash_nokpacl_name_' + i).val(db_nokpacl["merlinclash_nokpacl_name_" + i]);
				$('#merlinclash_nokpacl_mac_' + i).val(db_nokpacl["merlinclash_nokpacl_mac_" + i]);
			}
			if(db_merlinclash["merlinclash_nokpacl_default_mode"]){
				$('#merlinclash_nokpacl_default_mode').val(db_merlinclash["merlinclash_nokpacl_default_mode"]);
			}
			//set default rule port to all when game mode enabled
			set_nodefault_port();
			//after table generated and value filled, set default value for first line_image1
			$('#merlinclash_nokpacl_mode').val("0");
			$('#merlinclash_nokpacl_port').val("all");
		}
	});
}
function set_nomode_1() {
	//set the first line of the table, if mode is gfwlist mode or game mode,set the port to all
	if ($('#merlinclash_nokpacl_mode').val() == 0) {
		$("#merlinclash_nokpacl_port").val("all");
		E("merlinclash_nokpacl_port").readOnly = "readonly";
		E("merlinclash_nokpacl_port").title = "不可更改，不走代理下默认全端口";
	} else if ($('#merlinclash_nokpacl_mode').val() == 1) {
		//console.log($('#merlinclash_nokpacl_mode').val());
		$("#merlinclash_nokpacl_port").val("80,443");
		E("merlinclash_nokpacl_port").readOnly = "";
		E("merlinclash_nokpacl_port").title = "";
	}
}
function set_nomode_2(o) {
	var id2 = $(o).attr("id");
	var ids2 = id2.split("_");
	id2 = ids2[ids2.length - 1];
	if ($(o).val() == 0) {
		$("#merlinclash_nokpacl_port_" + id2).val("all");
		E("merlinclash_nokpacl_port_" + id2).readOnly = "readonly";
	} else if ($(o).val() == 1) {
		$("#merlinclash_nokpacl_port_" + id2).val("all");
		E("merlinclash_nokpacl_port_" + id2).readOnly = "";
	} else if ($(o).val() == 2) {
		$("#merlinclash_nokpacl_port_" + id2).val("22,80,443");
	}
}
function set_nodefault_port() {
	//console.log($('#merlinclash_nokpacl_default_mode').val());
	if ($('#merlinclash_nokpacl_default_mode').val() == 0) {
		$("#merlinclash_nokpacl_default_port").val("all");
		E("merlinclash_nokpacl_default_port").readOnly = "readonly";
		E("merlinclash_nokpacl_default_port").title = "不可更改，不走代理下默认全端口";
	} else {

		//$("#merlinclash_nokpacl_default_port").val("all");
		//console.log(db_merlinclash["merlinclash_nokpacl_default_port"]);
		if(db_merlinclash["merlinclash_nokpacl_default_port"]){
			$("#merlinclash_nokpacl_default_port").val(db_merlinclash["merlinclash_nokpacl_default_port"]);
		}else{
			$("#merlinclash_nokpacl_default_port").val("all");
		}

		E("merlinclash_nokpacl_default_port").readOnly = "";
		E("merlinclash_nokpacl_default_port").title = "";
	}
}
function refresh_nokpacl_html() {
	nokpacl_confs = getnoKPACLConfigs();
	var n = 0;
	for (var i in nokpacl_confs) {
		n++;
	}
	var code = '';
	// acl table th
	code += '<table width="750px" border="0" align="center" cellpadding="4" cellspacing="0" class="FormTable_table nokpacl_lists" style="margin:-1px 0px 0px 0px;">'
	code += '<tr>'
	code += '<th width="20%">主机IP地址</th>'
	code += '<th width="20%">主机MAC地址</th>'
	code += '<th width="22%">主机别名</th>'
	code += '<th width="15%">访问控制</th>'
	code += '<th width="15%">目标端口</th>'
	code += '<th width="8%">操作</th>'
	code += '</tr>'
	code += '</table>'
	// acl table input area
	code += '<table id="noKPACL_table" width="750px" border="0" align="center" cellpadding="4" cellspacing="0" class="list_table nokpacl_lists" style="margin:-1px 0px 0px 0px;">'
	code += '<tr>'
	// ip addr merlinclash_nokpacl_ip 主机IP地址
	code += '<td width="20%">'
	code += '<input type="text" maxlength="15" class="input_15_table" id="merlinclash_nokpacl_ip" align="left" style="float:left;width:110px;margin-left:0px;text-align:center" autocomplete="off" onClick="hidenokpClients_Block();" autocorrect="off" autocapitalize="off">'
	code += '<img id="pull_arrow" height="14px;" src="images/arrow-down.gif" align="right" onclick="pullnokpLANIPList(this);" title="<#select_IP#>">'
	code += '<div id="nokpClientList_Block" class="clientlist_dropdown" style="margin-left:2px;margin-top:25px;"></div>'
	code += '</td>'
	// name merlinclash_nokpacl_mac 主机MAC地址
	code += '<td width="20%">'
	code += '<input type="text" id="merlinclash_nokpacl_mac" class="input_15_table" maxlength="50" style="width:133px;text-align:center" placeholder="" />'
	code += '</td>'
	// name merlinclash_kpacl_name 主机别名
	code += '<td width="22%">'
	code += '<input type="text" id="merlinclash_nokpacl_name" class="input_15_table" maxlength="50" style="width:133px;text-align:center" placeholder="" />'
	code += '</td>'
	// mode merlinclash_kpacl_mode 访问控制
	code += '<td width="15%">'
	code += '<select id="merlinclash_nokpacl_mode" style="width:100px;margin:0px 0px 0px 2px;text-align:center;text-align-last:center;padding-left: 0px;" class="input_option" onchange="set_nomode_1(this);">'
	code += '<option value="0">不通过代理</option>'
	code += '<option value="1">通过clash</option>'
	code += '</select>'
	code += '</td>'
	// port merlinclash_kpacl_port 目标端口
	code += '<td width="15%">'
	code += '<select id="merlinclash_nokpacl_port" style="width:100px;margin:0px 0px 0px 2px;text-align-last:center;padding-left: 0px;" class="input_option">'
	code += '<option value="all">all</option>'
	code += '<option value="80,443">80,443</option>'
	code += '<option value="22,80,443">22,80,443</option>'
	code += '</select>'
	code += '</td>'
	// add/delete 按钮
	code += '<td width="8%">'
	code += '<input style="margin-left: 6px;margin: -2px 0px -4px -2px;" type="button" class="add_btn" onclick="addnokpaclTr()" value="" />'
	code += '</td>'
	code += '</tr>'
	// acl table rule area
	for (var field in nokpacl_confs) {
		var nokp = nokpacl_confs[field];
		code += '<tr id="nokpacl_tr_' + nokp["nokpacl_node"] + '">';
		// ip merlinclash_nokpacl_ip 主机IP地址
		code += '<td width="20%">' + nokp["ip"] + '</td>';
		//merlinclash_nokpacl_mac 主机MAC地址
		code += '<td width="20%">';
		code += '<input type="text" placeholder="' + nokp["nokpacl_node"] + '号机" id="merlinclash_nokpacl_mac_' + nokp["nokpacl_node"] + '" name="merlinclash_nokpacl_mac_' + nokp["nokpacl_node"] + '" class="input_option_2" maxlength="50" style="width:133px;" placeholder="" />';
		code += '</td>';
		//merlinclash_nokpacl_name 主机别名
		code += '<td width="22%">';
		code += '<input type="text" placeholder="' + nokp["nokpacl_node"] + '号机" id="merlinclash_nokpacl_name_' + nokp["nokpacl_node"] + '" name="merlinclash_nokpacl_name_' + nokp["nokpacl_node"] + '" class="input_option_2" maxlength="50" style="width:133px;" placeholder="" />';
		code += '</td>';
		//merlinclash_nokpacl_mode 访问控制
		code += '<td width="15%">';
		code += '<select id="merlinclash_nokpacl_mode_' + nokp["nokpacl_node"] + '" name="merlinclash_nokpacl_mode_' + nokp["nokpacl_node"] + '" style="width:100px;margin:0px 0px 0px 2px;" class="sel_option" onchange="set_nomode_2(this);">';
		code += '<option value="0">不通过代理</option>';
		code += '<option value="1">通过clash</option>';
		code += '</select>'
		code += '</td>';
		//merlinclash_nokpacl_port 目标端口
		code += '<td width="15%">';
		if (nokp["mode"] == 0) {
			code += '<input type="text" id="merlinclash_nokpacl_port_' + nokp["nokpacl_node"] + '" name="merlinclash_nokpacl_port_' + nokp["nokpacl_node"] + '" class="input_option_2" maxlength="50" style="width:100px;" title="不可更改，不通过clash下默认全端口" readonly = "readonly" />';
		} else {
			code += '<input type="text" id="merlinclash_nokpacl_port_' + nokp["nokpacl_node"] + '" name="merlinclash_nokpacl_port_' + nokp["nokpacl_node"] + '" class="input_option_2" maxlength="50" style="width:100px;" placeholder="" />';
		}
		code += '</td>';
		//按钮
		code += '<td width="8%">';
		code += '<input style="margin: -2px 0px -4px -2px;" id="nokpacl_node_' + nokp["nokpacl_node"] + '" class="remove_btn" type="button" onclick="delnokpaclTr(this);" value="">'
		code += '</td>';
		code += '</tr>';
	}
	//底行
	code += '<tr>';
	//所有主机
	if (n == 0) {
		code += '<td width="20%">所有主机</td>';
	} else {
		code += '<td width="20%">其它主机</td>';
	}
	//默认规则
	code += '<td width="20%">默认规则</td>';
	//默认规则
	if (n == 0) {
		code += '<td width="20%">所有主机</td>';
	} else {
		code += '<td width="20%">其它主机</td>';
	}
	//访问控制

	code += '<td width="15%">';
	code += '<select id="merlinclash_nokpacl_default_mode" style="width:100px;margin:0px 0px 0px 2px;" class="sel_option" onchange="set_nodefault_port();">';
	code += '<option value="0">不通过代理</option>';
	code += '<option value="1" selected>通过clash</option>';
	code += '</select>';
	code += '</td>';

	//默认端口
	code += '<td width="15%">';
	code += '<input type="text" id="merlinclash_nokpacl_default_port" class="input_option_2" maxlength="50" style="width:100px;" placeholder="" />';
	code += '</td>';
	//按钮为空
	code += '<td width="8%">';
	code += '</td>';
	code += '</tr>';
	code += '</table>';

	$(".nokpacl_lists").remove();
	$('#merlinclash_nokpacl_table').after(code);

	showDropdownClientList('setnokpClientIP', 'ip>mac>name', 'all', 'nokpClientList_Block', 'pull_arrow', 'online');
}
function setnokpClientIP(ip, mac, name) {
	E("merlinclash_nokpacl_ip").value = ip;
	E("merlinclash_nokpacl_mac").value = mac;
	E("merlinclash_nokpacl_name").value = name;
	hidenokpClients_Block();
}
function pullnokpLANIPList(obj) {
	var element = E('nokpClientList_Block');
	var isMenuopen = element.offsetWidth > 0 || element.offsetHeight > 0;
	if (isMenuopen == 0) {
		obj.src = "/images/arrow-top.gif"
		element.style.display = 'block';
	} else{
		hidenokpClients_Block();
	}
}
function hidenokpClients_Block() {
	E("pull_arrow").src = "/images/arrow-down.gif";
	E('nokpClientList_Block').style.display = 'none';
}
//----------------------------访问控制部分END----------------------------------//

//-----------------------删除所有自定规则 开始----------------------//
function delallaclconfigs() {
	layer.confirm('<li>确定删除所有自定义规则吗？</li>', {
		shade: 0.8,
	}, function(index) {
		getaclconfigsmax();
		if(acl_node_max != "undefined"){
			var p = "merlinclash_acl";
			acl_node_del = acl_node_max;
			var acls = {};
			var params = ["type", "content", "lianjie", "protocol"];
			for (var j=acl_node_del; j>0; j--) {
				for (var i = 0; i < params.length; i++) {
					db_merlinclash[p + "_" + params[i] + "_" + j] = acls[p + "_" + params[i] + "_" + j] = "";
				}
			}
			acl_node_max = 0;
			var id = parseInt(Math.random() * 100000000);
			var postData = {"id": id, "method": "dummy_script.sh", "params":[], "fields": acls};

			intoQueue({
				type: "POST",
				cache:false,
				url: "/_api/",
				data: JSON.stringify(postData),
				dataType: "json",
				success: function(response) {
					refresh_acl_table();
					refreshpage();
				}
			});
		}
		layer.close(index);
		return true;
	}, function(index) {
		layer.close(index);
		return false;
	});
}
function getaclconfigsmax(){
	intoQueue({
		type: "GET",
		url: "/_api/merlinclash_acl",
		dataType: "json",
		async: false,
		success: function(data) {
			db_acls = data.result[0];
			getACLConfigs();
			//after table generated and value filled, set default value for first line_image1
		}
	});
}
//-----------------------删除所有自定规则 结束----------------------//
	var merlinclash = {
		checkIP: () => {
},
}
</script>
</head>
<body id="app" skin='<% nvram_get("sc_skin"); %>' onload="init();">
	<div id="TopBanner"></div>
	<div id="Loading" class="popup_bg"></div>
	<div id="LoadingBar" class="popup_bar_bg_ks" style="z-index: 200;" >
		<table cellpadding="5" cellspacing="0" id="loadingBarBlock" class="loadingBarBlock" align="center">
			<tr>
				<td height="100">
					<div id="loading_block3" style="margin:10px auto;margin-left:10px;width:85%; font-size:12pt;"></div>
					<div id="loading_block2" style="margin:10px auto;width:95%;"></div>
					<div id="log_content2" style="margin-left:15px;margin-right:15px;margin-top:10px;overflow:hidden">
						<textarea cols="50" rows="30" wrap="off" readonly="readonly" id="log_content3" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false" style="border:1px solid #000;width:99%; font-family:'Lucida Console'; font-size:11px;background:transparent;color:#FFFFFF;outline: none;padding-left:3px;padding-right:22px;overflow-x:hidden"></textarea>
					</div>
					<div id="ok_button" class="apply_gen" style="background: #000;display: none;">
						<input id="ok_button1" class="button_gen" type="button" onclick="hideMCLoadingBar()" value="确定">
					</div>
				</td>
			</tr>
		</table>
	</div>
	<table class="content" align="center" cellpadding="0" cellspacing="0">
		<tr>
			<td width="17">&nbsp;</td>
			<td valign="top" width="202">
				<div id="mainMenu"></div>
				<div id="subMenu"></div>
			</td>
			<td valign="top">
				<div id="tabMenu" class="submenuBlock"></div>
				<table width="98%" border="0" align="left" cellpadding="0" cellspacing="0" style="display: block;">
					<tr>
						<td align="left" valign="top">
							<div>
								<table width="760px" border="0" cellpadding="5" cellspacing="0" bordercolor="#6b8fa3" class="FormTitle" id="FormTitle">
									<tr>
										<td bgcolor="#4D595D" colspan="3" valign="top">
											<div>&nbsp;</div>
											<div class="formfonttitle">Merlin Clash 2</div>
											<div style="float:right; width:15px; height:25px;margin-top:-20px">
												<img id="return_btn" onclick="reload_Soft_Center();" align="right" style="cursor:pointer;position:absolute;margin-left:-30px;margin-top:-25px;" title="返回软件中心" src="/images/backprev.png" onMouseOver="this.src='/images/backprevclick.png'" onMouseOut="this.src='/images/backprev.png'"></img>
											</div>
											<div style="margin:10px 0 10px 5px;" class="splitLine"></div>
											<div class="SimpleNote" id="head_illustrate"><i></i>
												<p>Merlin Clash2</u></em></a>是一个基于<a href='https://github.com/MetaCubeX/mihomo' target='_blank'><em><u>Mihomo内核</u></em></a>的代理程序，支持<em>SS</em>、<em>SSR</em>、<em>Vemss</em>、<em>Vless</em>、<em>Trojan</em>、<em>Hysteria</em>等协议科学上网。</p>
												<p>&nbsp;</p>
												<p id="showmsg1"></p>
												<p id="showmsg2"></p>
												<p id="showmsg3"></p>
												<p id="showmsg4"></p>
												<p id="showmsg5"></p>
												<p id="showmsg6"></p>
												<p id="showmsg7"></p>
												<p id="showmsg8"></p>
												<p id="showmsg9"></p>
												<p id="showmsg10"></p>
											</div>
											<!-- this is the popup area for process status -->
											<div id="detail_status"  class="content_status" style="box-shadow: 3px 3px 10px #000;margin-top: -20px;display: none;">
												<div class="user_title">【Merlin Clash】状态检测</div>
												<div style="margin-left:15px"><i>&nbsp;&nbsp;目前本功能支持Merlin Clash相关进程状态和iptables表状态检测。</i></div>
												<div style="margin: 10px 10px 10px 10px;width:98%;text-align:center;overflow:hidden">
													<textarea cols="63" rows="36" wrap="off" id="proc_status" style="width:98%;padding-left:13px;padding-right:33px;border:0px solid #222;font-family:'Lucida Console'; font-size:11px;background: transparent;color:#FFFFFF;outline: none;overflow-x:hidden;" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false"></textarea>
												</div>
												<div style="margin-top:5px;padding-bottom:10px;width:100%;text-align:center;">
													<input class="button_gen" type="button" onclick="close_proc_status();" value="返回主界面">
												</div>
											</div>
											<div id="snifferrules_settings" class="contentMKP_qis" style="box-shadow: 3px 3px 10px #000;margin-top: -65px;display: none;">
												<div class="user_title">Sniffer域名嗅探黑白名单设置</div>
												<div style="margin-left:15px"><i>1&nbsp;&nbsp;点击【保存文件】按钮，文本框内的内容会保存到/koolshare/merlinclash/yaml_basic/sniffer.yaml；</i></div>
												<div style="margin-left:15px"><i>2&nbsp;&nbsp;更改配置内容后，需要重启Merlin Clash才能生效；</i></div>
												<div style="margin-left:15px"><i>3&nbsp;&nbsp;更多设置内容，请查阅https://docs.metacubex.one/function/dns/sniffer。</i></div>
												<div id="snifferrules_tr" style="margin: 10px 10px 10px 10px;width:98%;text-align:center;">
													<textarea cols="63" rows="16" wrap="off" id="snifferrulestxt" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false"style="width: 940px; background: black; color: white; resize: none;"></textarea>
												</div>
												<div style="margin-top:5px;padding-bottom:10px;width:100%;text-align:center;">
													<input id="edit_node" class="button_gen" type="button" onclick="savesniffer();" value="保存设置">
													<input id="edit_node" class="button_gen" type="button" onclick="close_sniffer();" value="返回主界面">
												</div>
											</div>
											<!-- this is the popup area for regular log -->
											<div id="regular_log_status"  class="content_status" style="box-shadow: 3px 3px 10px #000;margin-top: -20px;display: none;">
												<div class="user_title">【Merlin Clash】订阅定时更新日志</div>
												<div style="margin: 10px 10px 10px 10px;width:98%;text-align:center;overflow:hidden">
													<textarea cols="63" rows="36" wrap="off" id="regular_log" style="width:98%;padding-left:13px;padding-right:33px;border:0px solid #222;font-family:'Lucida Console'; font-size:11px;background: transparent;color:#FFFFFF;outline: none;overflow-x:hidden;" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false"></textarea>
												</div>
												<div style="margin-top:5px;padding-bottom:10px;width:100%;text-align:center;">
													<input class="button_gen" type="button" onclick="close_regular_log();" value="返回主界面">
												</div>
											</div>
											<div id="merlinclash_switch_show" style="margin:-1px 0px 0px 0px;">
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_switch_table">
													<thead>
														<tr>
															<td colspan="2">开关</td>
														</tr>
													</thead>
													<tr>
														<th id="merlinclash_switch">Merlin Clash开关</th>
														<td colspan="2">
															<div class="switch_field" style="display:table-cell;float: left;">
																<label for="merlinclash_enable">
																	<input id="merlinclash_enable" class="switch" type="checkbox" style="display: none;">
																	<div class="switch_container" >
																		<div class="switch_bar"></div>
																		<div class="switch_circle transition_style">
																			<div></div>
																		</div>
																	</div>
																</label>
															</div>
															<div id="merlinclash_version_show" style="display:table-cell;float: left;position: absolute;margin-left:70px;padding: 5.5px 0px;">
																<a class="hintstyle">
																	<i>当前版本：</i>
																</a>
															</div>
															<div style="display:table-cell;float: left;margin-left:250px;position: absolute;padding: 5.5px 0px;">
																<a type="button" class="ks_btn" style="cursor:pointer" onclick="get_proc_status()" href="javascript:void(0);">详细状态</a>
															</div>
														</td>
													</tr>
													<tr>
														<th>程序内核版本</th>
														<td colspan="2">
															<div style="display:table-cell;float: left;margin-left:0px; text-align: right;">
																<div id="merlinclash_core_version">
																	<span id="core_state1">clash：</span>
																</div>
															</div>
														</td>
													</tr>
												</table>
												<table style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >
													<thead>
														<tr>
															<td colspan="2">状态检查</td>
														</tr>
													</thead>
													<tr id="clash_state">
														<th class="sp_bottom_line">插件运行状态</th>
														<td class="sp_bottom_line">
															<div style="display:table-cell;float: left;margin-left:0px;">
																<span id="clash_state1">Clash 启动时间 - Waiting...</span>
																<br/>
																<span id="clash_state2">Clash 进程状态 - Waiting...</span>
																<br id="br1"/>
																	<span id="clash_state3">Clash 实时守护进程 - Waiting...</span>
																</div>
															</td>
														</tr>
														<tr id="ip_state">
															<th>连通性检查</th>
															<td>
																<div style="padding-right: 20px;">
																	<div style="display: flex;">
																		<div style="width: 61.8%">IP 地址检查</div>
																		<div style="width: 40%">网站访问检查</div>
																	</div>
																</div>
																<div>
																	<div style="display: flex;">
																		<div style="width: 61.8%">
																			<p><span class="ip-title">国内</span>:&nbsp;<span id="ip-ipipnet">Waiting....</span></p>
																			<p><span class="ip-title">海外</span>:&nbsp;<span id="ip-ipapi">Waiting....</span>&nbsp;<span id="ip-ipapi-geo"></span></p>
																		</div>
																		<div style="width: 40%">

																			<p><span class="ip-title">国内</span>&nbsp;:&nbsp;<span id="http-baidu">Waiting....</span></p>
																			<p><span class="ip-title">海外</span>&nbsp;:&nbsp;<span id="http-google">Waiting....</span></p>
																		</div>
																	</div>
																</div>
															</td>
														</tr>
													</table>
												</div>
												<div id="tablets">
													<table style="margin:10px 0px 0px 0px;border-collapse:collapse" width="100%" height="37px">
														<tr>
															<td cellpadding="0" cellspacing="0" style="padding:0" border="1" bordercolor="#222">
																<input id="show_btn0" class="show-btn0" style="cursor:pointer" type="button" value="首页功能" /> <input id="show_btn88" class="show-btn88" style="cursor:pointer" type="button" value="切换线路" />
																<input id="show_btn1" class="show-btn1" style="cursor:pointer" type="button" value="配置文件" />
																<input id="show_btn2" class="show-btn2" style="cursor:pointer" type="button" value="自定规则" />
																<input id="show_btn9" class="show-btn9" style="cursor:pointer" type="button" value="访问控制" />
																<input id="show_btn3" class="show-btn3" style="cursor:pointer" type="button" value="高级模式" />
																<input id="show_btn4" class="show-btn4" style="cursor:pointer" type="button" value="附加功能" />
																<input id="show_btn7" class="show-btn7" style="cursor:pointer" type="button" value="日志记录" />
																<input id="show_btn6" class="show-btn6" style="cursor:pointer" type="button" value="当前配置" />
																<input id="show_btn10" class="show-btn10" style="cursor:pointer" type="button" value="DC用户" />
															</td>
														</tr>
													</table>
												</div>
												<!--首页功能区-->
												<div id="tablet_0" style="display: none;">
													<div id="merlinclash-content-overview">
														<div id="merlinclash-yamls" style="margin:-1px 0px 0px 0px;">
															<form name="form1">
																<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >
																	<thead>
																		<tr>
																			<td colspan="2">配置文件</td>
																		</tr>
																	</thead>
																	<tr id="yamlselect">
																		<th>配置文件选择</th>
																		<td colspan="2">
																			<select id="merlinclash_yamlsel"  name="yamlsel" dataType="Notnull" msg="配置文件不能为空!" class="input_option" ></select>
																		</td>
																	</tr>
																</table>
															</form>
														</div>
														<div id="merlinclash-mode" style="margin:-1px 0px 0px 0px;">
															<table style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >
																<thead>
																	<tr>
																		<td colspan="2">运行模式</td>
																	</tr>
																</thead>
																<tr id="dns_plan">
																	<th><a class="hintstyle" >运行模式 -- 点击切换直接生效</a></th>
																	<td colspan="2">
																		<label for="merlinclash_clashmode">
																			<input id="merlinclash_clashmode" type="radio" name="clashmode" value="default" checked="checked">使用配置文件设定
																			<input id="merlinclash_clashmode" type="radio" name="clashmode" value="rule">规则模式
																			<input id="merlinclash_clashmode" type="radio" name="clashmode" value="global">全局模式
																			<input id="merlinclash_clashmode" type="radio" name="clashmode" value="direct">直连模式
																			<!-- <input id="merlinclash_clashmode" type="radio" name="clashmode" value="script">脚本模式 -->
																		</label>
																		<script>
																			$("[name='clashmode']").on("change",
																				function (e) {
																		//console.log($(e.target).val());
																		var mode_tag=$(e.target).val();
																		//alert(dns_tag);
																		PATCH_MODE(mode_tag);
																	}
																	);
																</script>
															</td>
														</tr>
													</table>
												</div>
												<div id="merlinclash-dns" style="margin:-1px 0px 0px 0px;">
													<table style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >
														<thead>
															<tr>
																<td colspan="2">DNS方案</td>
															</tr>
														</thead>
														<tr id="dns_plan">
															<th><a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(1)">DNS方案</a></th>
															<td colspan="2">
																<label for="merlinclash_dnsplan">
																	<input id="merlinclash_dnsplan" type="radio" name="dnsplan" value="rh" checked="checked">默认:Redir-Host&nbsp;&nbsp;&nbsp;&nbsp;
																	<input id="merlinclash_dnsplan" type="radio" name="dnsplan" value="fi">Fake-ip&nbsp;&nbsp;&nbsp;&nbsp;
																</label>
																			<p style="color:#FC0">&nbsp;</p>
																			<p style="color:#FC0">1.默认为Redir-Host，兼容性良好，不正确的设置DNS可能被污染；</p>
																			<p style="color:#FC0">2.Fake-ip，拒绝DNS污染。无法获得真实IP，部分游戏/P2P请求可能无法连接；</p>
																			<p style="color:#FC0">3.Clash的DNS工作原理请查阅【<a href="https://github.com/Fndroid/clash_for_windows_pkg/wiki/DNS%E6%B1%A1%E6%9F%93%E5%AF%B9Clash%EF%BC%88for-Windows%EF%BC%89%E7%9A%84%E5%BD%B1%E5%93%8D" target="_blank"><em><u>DNS污染对Clash的影响</u></em></a>】；</p>
																			<p style="color:#FC0">4.各模式DNS可通过附加功能的【<a style="cursor:pointer" onclick="dnsplan()" href="javascript:void(0);"><em><u>DNS编辑</em></u></a>】自行设置。</p>
																		</td>
																	</tr>
																	<tr id="dns_fakeipblack">
																		<th><a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(28)">黑名单设备解析服务器</a></th>
																		<td colspan="2">
																			<div class="SimpleNote" id="head_illustrate">
																				<input id="merlinclash_dns_fakeipblack" class="input_15_table" value="223.5.5.5">
																			</div>
																		</td>
																	</tr>
																	<tr id="dns_hijack">
																		<th>DNS劫持</th>
																		<td colspan="2">
																			<label for="merlinclash_dnshijack">
																				<input id="merlinclash_dnshijack" type="radio" name="dnshijack" value="front" checked="checked">默认:劫持&nbsp;&nbsp;&nbsp;&nbsp;
																				<input id="merlinclash_dnshijack" type="radio" name="dnshijack" value="rear">不劫持
																			</label>
																			<p style="color:#FC0">默认：劫持局域网内所有DNS请求，防止因设备自定义DNS造成DNS污染</p>
																			<p style="color:#FC0">不劫持：设备DNS必须为路由IP</p>
																		</td>
																	</tr>															
																</table>
															</div>
															<table style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_switch_table">
																<thead>
																	<tr>
																		<td colspan="2">Clash管理面板</td>
																	</tr>
																</thead>
																<tr id="clash_dashboard">
																	<th>面板信息</th>
																	<td>
																		<div style="display:table-cell;float: left;margin-left:0px;">
																			<span id="dashboard_state2">管理面板</span>&nbsp;|&nbsp;<span id="dashboard_state4">面板密码</span>
																		</div>
																	</td>
																</tr>
																<tr>
																	<th>访问 Clash 管理面板</th>
																	<td colspan="2">
																		<div class="merlinclash-btn-container">
																			<a type="button" id="zash" ></a>
																			<p style="margin-top: 8px">只有在 Clash 正在运行的时候才可以访问 Clash 管理面板</p>
																		</div>
																	</td>
																</tr>
															</table>
															<table style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_switch_table">
																<thead>
																	<tr>
																		<td colspan="2">排障与重启</td>
																	</tr>
																</thead>
																<tr>
																	<th><a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(27)">重建服务</a></th>
																	<td colspan="2">
																		<div class="merlinclash-btn-container">
																			<a type="button" style="vertical-align: middle; cursor:pointer;" class="ks_btn" id="selectlist" onclick="selectlist_rebuild()">&nbsp;&nbsp;重建下拉列表&nbsp;&nbsp;</a>
																		</div>
																	</td>
																</tr>
																<tr>
																	<th><a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(25)">强制关闭 Merlin Clash</a></th>
																	<td colspan="2">
																		<div class="merlinclash-btn-container">
																			<a type="button" style="vertical-align: middle; cursor:pointer;" class="ks_btn" id="hot_off" onclick="hot_off_mc()">&nbsp;&nbsp;热关闭&nbsp;&nbsp;</a>
																			<a type="button" style="vertical-align: middle; cursor:pointer;" class="ks_btn" id="cool_off" onclick="cool_off_mc()">&nbsp;&nbsp;冷关闭&nbsp;&nbsp;</a>
																		</div>
																	</td>
																</tr>
																<tr id="clash_restart_job_tr">
																	<th>
																		<label >定时重启</label>
																	</th>
																	<td>
																		<select name="select_clash_restart" id="merlinclash_select_clash_restart" onChange="show_job()"  class="input_option" style="margin:-1 0 0 10px;">
																			<option value="1" selected>关闭</option>
																			<option value="5">每隔</option>
																			<option value="2">每天</option>
																			<option value="3">每周</option>
																			<option value="4">每月</option>
																		</select>
																		<select name="select_clash_restart_day" id="merlinclash_select_clash_restart_day" class="input_option" ></select>
																		<select name="select_clash_restart_week" id="merlinclash_select_clash_restart_week" class="input_option" ></select>
																		<select name="select_clash_restart_hour"  id="merlinclash_select_clash_restart_hour" class="input_option" ></select>
																		<select name="select_clash_restart_minute"  id="merlinclash_select_clash_restart_minute" class="input_option" ></select>
																		<select name="select_clash_restart_minute_2"  id="merlinclash_select_clash_restart_minute_2" class="input_option" ></select>
																		<input  type="button" id="merlinclash_select_clash_restart_save" class="ks_btn" style="vertical-align: middle; cursor:pointer;" onclick="clash_restart_save();" value="保存设置" />
																	</td>
																</tr>
																<tr>
																	<th>二进制日志</th>
																	<td colspan="2">
																		<div class="merlinclash-btn-outputlog">
																			<a type="button" style="vertical-align: middle; cursor:pointer;" class="ks_btn" id="outputlog" onclick="outputlog()">&nbsp;&nbsp;导出日志&nbsp;&nbsp;</a>
																		</div>
																	</td>
																</tr>
															</table>
														</div>
													</div><!--切换线路--><!--切换线路--><div id="tablet_88" style="display: none;"><div id="changenodelist"><div id="zash-board"></div></div><div style="margin:10px 0 0 5px"><div><i>&nbsp;&nbsp;1.本页面集成zash面板显示；<br>&nbsp;&nbsp;2.除了切换线路，其他不明白的设置请不要随意操作。<br>&nbsp;&nbsp;3.如有问题卸载删除插件、清除浏览器缓存再次安装</i></div></div></div>
													<!--配置文件-->
													<div id="tablet_1" style="display: none;">
														<div id="merlinclash-content-config" style="margin:-1px 0px 0px 0px;">
															<table  id="clashimport" style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >
																<thead>
																	<tr>
																		<td colspan="2">导入Clash配置文件</td>
																	</tr>
																</thead>
																<tr>
																	<th>手动上传Clash配置文件&nbsp;&nbsp;<a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(10)"><em style="color: gold;">【上传必看】</em></a></th>
																	<td colspan="2">
																		<div class="SimpleNote" style="display:table-cell;float: left; height: 110px; line-height: 110px; margin:-40px 0;">
																			<input type="file" id="clashconfig" size="50" name="file"/>
																			<span id="clashconfig_info" style="display:none;">完成</span>
																			<a type="button" style="vertical-align: middle; cursor:pointer;" id="clashconfig-btn-upload" class="ks_btn" onclick="upload_clashconfig()" >上传配置文件</a>
																		</div>
																	</td>
																</tr>
															</table>												
															<table style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_switch_table">
																<thead>
																	<tr>
																		<td colspan="2">其他订阅转换Clash规则&nbsp;&nbsp;&nbsp;&nbsp;<a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(6)"><em>【帮助】</em></td>
																		</tr>
																	</thead>
																	<tr id="subconverterlocal">
																		<th class="sp_bottom_line">
																			<p >SubConverter本地转换</p>
																			<br>
																			<br><em style="color: gold;">SS&nbsp;|&nbsp;SSR&nbsp;|&nbsp;V2ray订阅|&nbsp;Trojan订阅</em>
																			<br>
																			<br>																			
																		</th>
																		<td class="sp_bottom_line">
																			<div class="SimpleNote" style="display:table-cell;float: left;">
																				<textarea id="merlinclash_links3" warp="on" placeholder="&nbsp;&nbsp;&nbsp;请输入订阅连接（支持多个订阅地址，回车分行或用'|'隔开）" type="text"></textarea>
																			</div>
																			<div class="SimpleNote" style="display:table-cell;float: left; width: 400px;">
																				<span>emoji:</span>
																				<input id="merlinclash_subconverter_emoji" type="checkbox" name="subconverter_emoji" checked="checked">
																				<span>&nbsp;&nbsp;&nbsp;节点类型:</span>
																				<input id="merlinclash_subconverter_append_type" type="checkbox" name="subconverter_append_type">
																				<span>&nbsp;&nbsp;&nbsp;节点排序:</span>
																				<input id="merlinclash_subconverter_sort" type="checkbox" name="subconverter_sort">
																				<span>&nbsp;&nbsp;&nbsp;过滤非法节点:</span>
																				<input id="merlinclash_subconverter_fdn" type="checkbox" name="subconverter_fdn">
																				<br>
																				<span>跳过证书验证:</span>
																				<input id="merlinclash_subconverter_scv" type="checkbox" name="subconverter_scv">
																				<span>&nbsp;&nbsp;&nbsp;启用udp:</span>
																				<input id="merlinclash_subconverter_udp" type="checkbox" name="subconverter_udp" checked="checked">
																				<span>&nbsp;&nbsp;&nbsp;启用xudp:</span>
																				<input id="merlinclash_subconverter_xudp" type="checkbox" name="subconverter_xudp" checked="checked">
																				<span>&nbsp;&nbsp;&nbsp;TCP Fast Open:</span>
																				<input id="merlinclash_subconverter_tfo" type="checkbox" name="subconverter_tfo">
																			</div>
																			<div class="SimpleNote" style="display:table-cell;float: left; width: 400px;">
																				<p><label>包含节点：</label>
																					<input id="merlinclash_subconverter_include" class="input_25_table" style="width:320px" placeholder="&nbsp;筛选包含关键字的节点名，支持正则">
																				</p>
																				<br>
																				<p><label>排除节点：</label>
																					<input id="merlinclash_subconverter_exclude" class="input_25_table" style="width:320px" placeholder="&nbsp;过滤包含关键字的节点名，支持正则">
																				</p>
																				<br>																
																			</div>
																			<div class="SimpleNote" style="display:table-cell;float: left; width: 400px; height: 30px; line-height: 30px; ">
																				<select id="merlinclash_clashtarget" style="width:100px;margin:0px 0px 0px 0px;text-align:left;padding-left: 0px;" class="input_option">
																					<option value="clash">clash新参数</option>
																					<option value="clashr">clashR新参数</option>
																				</select>
																				<select id="merlinclash_acl4ssrsel" style="width:195px;margin:0px 0px 0px 2px;text-align:left;padding-left: 0px;" class="input_option">
																					<option value="ZHANG">Merlin Clash_常规规则</option>
																					<option value="ZHANG_NoAuto">Merlin Clash_常规无测速</option>
																					<option value="ZHANG_Media">Merlin Clash_多媒体全量</option>
																					<option value="ZHANG_Media_NoAuto">Merlin Clash_多媒体全量无测速</option>
																					<option value="ZHANG_Media_Area_UrlTest">Merlin Clash_多媒体全量分地区测速</option>
																					<option value="ZHANG_Media_Area_FallBack">Merlin Clash_多媒体全量分地区故障转移</option>
																					<option value="ACL4SSR_Online">Online默认版_分组比较全</option>
																					<option value="ACL4SSR_Online_AdblockPlus">AdblockPlus_更多去广告</option>
																					<option value="ACL4SSR_Online_NoAuto">NoAuto_无自动测速</option>
																					<option value="ACL4SSR_Online_NoReject">NoReject_无广告拦截规则</option>
																					<option value="ACL4SSR_Online_Mini">Mini_精简版</option>
																					<option value="ACL4SSR_Online_Mini_AdblockPlus">Mini_AdblockPlus_精简版更多去广告</option>
																					<option value="ACL4SSR_Online_Mini_NoAuto">Mini_NoAuto_精简版无自动测速</option>
																					<option value="ACL4SSR_Online_Mini_Fallback">Mini_Fallback_精简版带故障转移</option>
																					<option value="ACL4SSR_Online_Mini_MultiMode">Mini_MultiMode_精简版自动测速故障转移负载均衡</option>
																					<option value="ACL4SSR_Online_Full">Full全分组_重度用户使用</option>
																					<option value="ACL4SSR_Online_Full_NoAuto">Full全分组_无自动测速</option>
																					<option value="ACL4SSR_Online_Full_AdblockPlus">Full全分组_更多去广告</option>
																					<option value="ACL4SSR_Online_Full_Netflix">Full全分组_奈飞全量</option>
																					<option value="ACL4SSR_Online_Full_Google">Full全分组_谷歌细分</option>
																					<option value="ACL4SSR_Online_Full_MultiMode">Full全分组_多模式</option>
																					<option value="ACL4SSR_Online_Mini_MultiCountry">Full全分组_多国家地区</option>
																				</select>
																				<select id="merlinclash_acl4ssrsel_cus" style="width:195px;margin:0px 0px 0px 2px;text-align:left;padding-left: 0px;display: none;" class="input_option">
																				</select>
																				<input id="merlinclash_customrule_cbox" type="checkbox" name="merlinclash_customrule_cbox"><span id="merlinclash_customrule_cbox_span">&nbsp;使用自定订阅</span>
																				<script>
																					$("[name='merlinclash_customrule_cbox']").on("change",
																						function (e) {
																							var mode_tag=$(e.target).val();
																							set_rulemode();
																						}
																						);
																					</script>
																					<input id="merlinclash_cdn_cbox" type="checkbox" name="merlinclash_cdn_cbox"><span id="merlinclash_cdn_cbox_span">&nbsp;CDN订阅</span>
																				</div>
																				<div class="SimpleNote" style="display:table-cell;float: left; height: 30px; line-height: 30px; ">
																					<label style="color: gold;">远程配置：</label>
																					<input id="merlinclash_uploadiniurl" class="input_25_table" style="width:255px" placeholder="&nbsp;请输入文件URL地址">
																					<input id="merlinclash_customurl_cbox" type="checkbox" name="merlinclash_customurl_cbox"><span>&nbsp;勾选使用</span>
																				</div>
																				<div class="SimpleNote" style="display:table-cell;float: left; height: 30px; line-height: 30px; ">
																					<label style="color: gold;">重命名：</label>
																					<input onkeyup="value=value.replace(/[^a-zA-Z0-9]/g,'')" id="merlinclash_uploadrename4" maxlength="20" class="input_25_table" style="width:255px" placeholder="&nbsp;重命名(支持20位数字/字母)">
																					<a type="button" style="vertical-align: middle; margin:-10px 10px;" class="ks_btn" style="cursor:pointer" onclick="get_online_yaml3(16)" href="javascript:void(0);">&nbsp;&nbsp;开始转换&nbsp;&nbsp;</a>
																				</div>
																			</td>
																		</tr>
																		<tr id="clashyamldown">
																			<th>
																				<br><a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(14)">Clash订阅下载</a>
																				<br>
																				<br><em style="color: gold;">Clash专用订阅&nbsp;|&nbsp;ACL4SSR等转换订阅</em>
																			</th>
																			<td>
																				<div class="SimpleNote" style="display:table-cell;float: left;">
																					<textarea id="merlinclash_links" warp="on" placeholder="&nbsp;&nbsp;&nbsp;请输入订阅连接（只支持单个订阅地址）" type="text"></textarea>
																				</div>
																				<div class="SimpleNote" style="display:table-cell;float: left; height: 110px; line-height: 110px; margin:-40px 0;">
																					<label style="color: gold;">重命名：</label>
																					<input onkeyup="value=value.replace(/[^a-zA-Z0-9]/g,'')" id="merlinclash_uploadrename" maxlength="20" class="input_25_table" style="width:255px" placeholder="&nbsp;重命名,支持20位数字/字母">
																					<a type="button" style="vertical-align: middle; margin:-10px 10px;" class="ks_btn" style="cursor:pointer" onclick="get_online_yaml(2)" href="javascript:void(0);">&nbsp;&nbsp;Clash订阅&nbsp;&nbsp;</a>
																				</div><script>function updateInputValue(){var content=document.getElementById('merlinclash_links').value;var nameMatch=content.match(/name=([^\s&]+)/);if(nameMatch){var nameValue=nameMatch[1];document.getElementById('merlinclash_uploadrename').value=nameValue;}else{var urlMatch=content.match(/https?:\/\/([^\/\s]+)/);if(urlMatch){var domain=urlMatch[1].split('.')[1];if(domain){document.getElementById('merlinclash_uploadrename').value=domain;}}}}document.getElementById('merlinclash_links').addEventListener('input',updateInputValue);document.getElementById('merlinclash_links').addEventListener('blur',updateInputValue);</script>
																			</td>
																		</tr>
																	</table>
																	<form name="form1">

																		<table style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >
																			<thead>
																				<tr>
																					<td colspan="2">订阅设置</td>
																				</tr>
																			</thead>
																			<tr id="delyamlselect">
																				<th class="sp_bottom_line">更新订阅&nbsp;&nbsp;<span id="clash_yamlsel">当前配置为：</span></th>
																				<td class="sp_bottom_line" colspan="2">
																					<div class="SimpleNote" style="display:table-cell;float: left; height: 110px; line-height: 110px; margin:-40px 0;">
																						<select id="merlinclash_delyamlsel"  name="delyamlsel" dataType="Notnull" msg="配置文件不能为空!" class="input_option"></select>
																						<a type="button" style="vertical-align: middle;" class="ks_btn" style="cursor:pointer" onclick="download_yaml_sel('downyaml')" href="javascript:void(0);">&nbsp;&nbsp;下载配置&nbsp;&nbsp;</a>
																						<a type="button" style="vertical-align: middle;" class="ks_btn" style="cursor:pointer" onclick="del_yaml_sel(0)" href="javascript:void(0);" >&nbsp;&nbsp;删除配置&nbsp;&nbsp;</a>
																						<a type="button" style="vertical-align: middle;" class="ks_btn" style="cursor:pointer" onclick="update_yaml_sel(0)" href="javascript:void(0);" >&nbsp;&nbsp;更新配置&nbsp;&nbsp;</a>
																					</div>
																				</td>
																			</tr>
																			<tr id="clash_regular_job_tr">
																				<th class="sp_bottom_line">
																					<label >定时订阅</label>
																				</th>
																				<td class="sp_bottom_line" >
																					<label for="merlinclash_subscribeplan">
																						<input id="merlinclash_subscribeplan" type="radio" name="subscribeplan" value="all" checked="checked">更新全部配置&nbsp;&nbsp;&nbsp;&nbsp;
																						<input id="merlinclash_subscribeplan" type="radio" name="subscribeplan" value="used">更新当前配置&nbsp;&nbsp;&nbsp;&nbsp;
																					</label>
																					<p></p>
																					<select name="select_regular_subscribe" id="merlinclash_select_regular_subscribe" onChange="show_job()"  class="input_option" style="margin:0 0 0 10px;">
																						<option value="1" selected>关闭</option>
																						<option value="5">每隔</option>
																						<option value="2">每天</option>
																						<option value="3">每周</option>
																						<option value="4">每月</option>
																					</select>
																					<select name="select_regular_day" id="merlinclash_select_regular_day" class="input_option" ></select>
																					<select name="select_regular_week" id="merlinclash_select_regular_week" class="input_option" ></select>
																					<select name="select_regular_hour"  id="merlinclash_select_regular_hour" class="input_option" ></select>
																					<select name="select_regular_minute"  id="merlinclash_select_regular_minute" class="input_option" ></select>
																					<select name="select_regular_minute_2"  id="merlinclash_select_regular_minute_2" class="input_option" ></select>
																					<a type="button" class="ks_btn" style="vertical-align: middle; cursor:pointer" onclick="regular_subscribe_save()" href="javascript:void(0);">&nbsp;&nbsp;保存设置&nbsp;&nbsp;</a>
																					<a type="button" class="ks_btn" style="vertical-align: middle; cursor:pointer" onclick="get_regular_log()" href="javascript:void(0);">&nbsp;&nbsp;查看日志&nbsp;&nbsp;</a>
																				</td>
																			</tr>
																			<tr>
																				<th>
																					<label >订阅UserAgent</label>
																				</th>
																				<td>
																					<div class="SimpleNote" id="head_illustrate">
																						<input id="merlinclash_useragent" style="width:320px" class="input_15_table" placeholder="">
																						<a type="button" class="ks_btn" style="vertical-align: middle; cursor:pointer" onclick="useragent_save()" href="javascript:void(0);">&nbsp;&nbsp;保存修改&nbsp;&nbsp;</a>
																					</div>
																				</td>
																			</tr>
																		</table>
																	</form>
																</div>
															</div>
															<!--日志记录-->
															<div id="tablet_7" style="display: none;">
																<div id="merlinclash-notelog" style="margin:-1px 0px 0px 0px;">
																	<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >
																		<thead>
																			<tr>
																				<td colspan="2"><em style="color: gold;">节点恢复日志/记录</em></td>
																			</tr>
																		</thead>
																	</table>
																	<div id="nodes_content" class="mc_outline" style="height: 160px;">
																		<textarea class="sbar" cols="63" rows="36" wrap="on" readonly="readonly" id="nodes_content1" style="margin: 0px; width: 709px; height: 150px; resize: none;"></textarea>
																	</div>
																</div>
																<div id="merlinclash-OPLOG" style="margin:5px 0px 0px 0px;">
																	<table style="margin:5px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >
																		<thead>
																			<tr>
																				<td colspan="2"><em style="color: gold;">操作日志</em></td>
																			</tr>
																		</thead>
																	</table>
																	<div id="log_content" class="mc_outline" style="margin-top:-1px;overflow:hidden;">
																		<textarea class="sbar" cols="63" rows="36" wrap="on" readonly="readonly" id="log_content1" style="margin: 0px; width: 709px; height: 800px; resize: none;"></textarea>
																	</div>
																</div>
															</div>
															<!--自定规则-->
															<div id="tablet_2" style="display: none;">
																<div id="custom_rule_plan">
																	<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >
																		<thead>
																			<tr>
																				<td colspan="2">自定规则</td>
																			</tr>
																		</thead>
																		<tr id="cusrule_plan">
																			<th><a class="hintstyle" >自定规则模式</a></th>
																			<td colspan="2">
																				<label for="merlinclash_cusrule_plan">
																					<input id="merlinclash_cusrule_plan" type="radio" name="cusruleplan" value="closed" checked="checked">关闭
																					<input id="merlinclash_cusrule_plan" type="radio" name="cusruleplan" value="easy">开启
																					<!--<input id="merlinclash_cusrule_plan" type="radio" name="cusruleplan" value="pro">专业模式-->
																				</label>
																				<script>
																					$("[name='cusruleplan']").on("change",
																						function (e) {
																		//console.log($(e.target).val());
																		var mode_tag=$(e.target).val();
																		//alert(dns_tag);
																		CUSRULE_MODE(mode_tag);
																	});
																</script>
															</td>
														</tr>
													</table>
												</div>
												<div id="merlinclash_cusrule_edit_content" class="mc_outline" style="margin-top:-1px;overflow:hidden;">
													<textarea rows="7" wrap="on" id="merlinclash_cusrule_edit_content1" name="cusrule_edit_content1" style="margin: 0px; width: 709px; height: 300px; resize: none;"></textarea>
													<div style="text-align:center;vertical-align:middel;"><input class="ks_btn" type="button" onclick="cusrulechange()" value="修改提交"></div>
												</div>
												<div id="merlinclash_acl_table">
												</div>
												<div id="clash_ipsetproxy_area">
													<table style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_ipset_table">
														<thead>
															<tr>
																<td colspan="2">IPtables转发白名单 - 强制转发到Clash -- <em style="color: gold;">【编辑完成后点击“修改提交”保存，提交后生效】|【开启编辑：<input id="merlinclash_ipsetedit_check" class="barcodeSavePrint1" type="checkbox" name="ipsetedit_check" >】</em></td>
															</tr>
															<script>
																$(function () {
																	$(".barcodeSavePrint1").click(function () {
																		if (this.checked==true){
																			document.getElementById("merlinclash_ipsetproxy_edit_content1").readOnly = false
																		}else{
																			document.getElementById("merlinclash_ipsetproxy_edit_content1").readOnly = true
																		}
																	})
																})
															</script>
														</thead>
													</table>
													<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_ipsetproxy_content_table">
														<tr id="ipsetproxy_edit_tr">
															<th>IP/域名集编辑 | 一行一个，可以带掩码声明</th>
															<td>
																<input class="ks_btn" type="button" onclick="ipsetchange()" value="修改提交">
															</td>
														</tr>
													</table>
													<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
														<div id="merlinclash_ipsetproxy_edit_content" style="margin-top:-1px;overflow:hidden;">
															<textarea rows="7" wrap="on" id="merlinclash_ipsetproxy_edit_content1" name="ipsetproxy_edit_content1" style="margin: 0px; width: 709px; height: 150px; resize: none;" readonly="true"></textarea>
														</div>
													</table>
												</div>
												<div id="clash_ipsetproxyarround_area">
													<table style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_ipsetarround_table">
														<thead>
															<tr>
																<td colspan="2">IPtables转发黑名单 - 强制绕行Clash -- <em style="color: gold;">【编辑完成后点击“修改提交”保存，提交后生效】|【开启编辑：<input id="merlinclash_ipsetarroundedit_check" class="barcodeSavePrint2" type="checkbox" name="ipsetarroundedit_check" >】</em></td>
															</tr>
															<script>
																$(function () {
																	$(".barcodeSavePrint2").click(function () {
																		if (this.checked==true){
																			document.getElementById("merlinclash_ipsetproxyarround_edit_content1").readOnly = false
																		}else{
																			document.getElementById("merlinclash_ipsetproxyarround_edit_content1").readOnly = true
																		}
																	})
																})
															</script>
														</thead>
													</table>
													<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_ipsetproxyarround_content_table">
														<tr id="ipsetproxyarround_edit_tr">
															<th>IP/域名集编辑 | 一行一个，可以带掩码声明</th>
															<td>
																<input class="ks_btn" type="button" onclick="ipsetarroundchange()" value="修改提交">
															</td>
														</tr>
													</table>
													<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
														<div id="merlinclash_ipsetproxyarround_edit_content" style="margin-top:-1px;overflow:hidden;">
															<textarea rows="7" wrap="on" id="merlinclash_ipsetproxyarround_edit_content1" name="ipsetproxyarround_edit_content1" style="margin: 0px; width: 709px; height: 150px; resize: none;" readonly="true"></textarea>
														</div>
													</table>
												</div>
												<table style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_switch_table">
													<thead>
														<tr>
															<td colspan="2">备份/恢复</td>
														</tr>
													</thead>
													<tr>
														<th>备份自定义规则</th>
														<td colspan="2">
															<a type="button" style="vertical-align: middle; cursor:pointer;" id="clashrestorerule-btn-download" class="ks_btn" onclick="down_clashrestorerule(1)" >导出自定义规则</a>
														</td>
													</tr>
													<tr>
														<th>恢复自定义规则</th>
														<td colspan="2">
															<div class="SimpleNote" style="display:table-cell;float: left; height: 110px; line-height: 110px; margin:-40px 0;">
																<input type="file" style="width: 200px;margin: 0,0,0,0px;" id="clashrestorerule" size="50" name="file"/>
																<span id="clashrestorerule_info" style="display:none;">完成</span>
																<a type="button" style="vertical-align: middle; cursor:pointer;" id="clashrestorerule-btn-upload" class="ks_btn" onclick="upload_clashrestorerule()" >恢复自定义规则</a>
															</div>
														</td>
													</tr>
												</table>
												<div id="ACL_note" style="margin:10px 0 0 5px">
													<div><i>&nbsp;&nbsp;1.全新订阅的配置必须正常启动一次，才可以正常添加自定义规则。</i></div>
													<div><i>&nbsp;&nbsp;<em>2.已经支持自定义规则随配置文件自动切换，启用新配置无需删除之前自定义规则。</em></i></div>
													<div><i>&nbsp;&nbsp;3.编辑新规则后，必须重启插件后才能生效；</i></div>
													<div><i>&nbsp;&nbsp;4.更多说明请点击表头查看，或者参阅【<a href="https://mcreadme.gitbook.io/mc/Advanced/Custom" target="_blank"><em><u>Merlin Clash帮助文档</u></em></a>】。</i></div>
													<div><i>&nbsp;</i></div>
												</div>
											</div>
											<!--访问控制-->
											<div id="tablet_9" style="display: none;">
												<div id="nokpacllist">
													<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_switch_table">
														<thead>
															<tr>
																<td colspan="2">访问控制</td>
															</tr>
														</thead>
														<tr id="wb_method_tr">
															<th>访问控制匹配方法</th>
															<td>
																<select name="merlinclash_nokpacl_method" id="merlinclash_nokpacl_method" class="input_option" style="width:127px;margin:0px 0px 0px 2px;" onchange="update_visibility();">
																	<option value="1" selected>IP + MAC匹配</option>
																	<option value="2">仅IP匹配</option>
																	<option value="3">仅MAC匹配</option>
																</select>
															</td>
														</tr>
													</table>
													<div id="merlinclash_nokpacl_table">
													</div>
												</div>
												<table style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_switch_table">
													<thead>
														<tr>
															<td colspan="2">备份/恢复</td>
														</tr>
													</thead>
													<tr>
														<th>备份访问控制</th>
														<td colspan="2">
															<a type="button" style="vertical-align: middle; cursor:pointer;" id="passdevice-btn-download" class="ks_btn" onclick="down_passdevice(1)" >导出访问控制</a>
														</td>
													</tr>
													<tr>
														<th>恢复访问控制</th>
														<td colspan="2">
															<div class="SimpleNote" style="display:table-cell;float: left; height: 110px; line-height: 110px; margin:-40px 0;">
																<input type="file" style="width: 200px;margin: 0,0,0,0px;" id="passdevice" size="50" name="file"/>
																<span id="passdevice_info" style="display:none;">完成</span>
																<a type="button" style="vertical-align: middle; cursor:pointer;" id="passdevice-btn-upload" class="ks_btn" onclick="upload_passdevice()" >恢复访问控制</a>
															</div>
														</td>
													</tr>
												</table>
												<div id="DEVICE_note" style="margin:10px 0 0 5px">
													<div><i>&nbsp;&nbsp;1.本功能通过iptables实现设备黑白名单，优先级高于Clash访问控制规则；<br>
														&nbsp;&nbsp;2.访问控制通过MAC地址甄别设备，请关闭iPhone等设备的随机MAC地址功能。<br>
														&nbsp;&nbsp;3.如果需要自定义端口范围，适用英文逗号和冒号，参考格式：80,443,5566:6677,7777:8888。<br>
													</i></div>
													<div><i>&nbsp;</i></div>
												</div>
											</div>
											<!--高级模式-->
											<div id="tablet_3" style="display: none;">
												<!--补丁更新 -->
												<div id="merlinclash-patch" style="margin:-1px 0px 0px 0px;">
													<!-- <table style="display: none;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >
														<thead>
															<tr>
																<td colspan="2">补丁更新</td>
															</tr>
														</thead>
														<tr>
															<th>安装补丁&nbsp;<span id="patch_version">【已装补丁版本】：</span></th>
															<td colspan="2">
																<div class="SimpleNote" style="display:table-cell;float: left; height: 110px; line-height: 110px; margin:-40px 0;">
																	<input type="file" id="clashpatch" size="50" name="file"/>
																	<span id="clashpatch_upload" style="display:none;">完成</span>
																	<a type="button" style="vertical-align: middle; cursor:pointer;" id="clashpatch-btn-upload" class="ks_btn" onclick="upload_clashpatch()" >上传补丁</a>
																</div>
															</td>
														</tr>
													</table> -->
													<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_switch_table">
														<thead>
															<tr>
																<td colspan="2">Merlin Clash&nbsp;&nbsp;进程守护</td>
															</tr>
														</thead>
														<tr>
															<th>Clash 实时进程守护</th>
															<td colspan="2">
																<div class="switch_field" style="display:table-cell;float: left;">
																	<label for="merlinclash_watchdog">
																		<input id="merlinclash_watchdog" class="switch" type="checkbox" style="display: none;">
																		<div class="switch_container" >
																			<div class="switch_bar"></div>
																			<div class="switch_circle transition_style">
																				<div></div>
																			</div>
																		</div>
																	</label>
																</div>
																<div class="SimpleNote" id="head_illustrate">
																	<p>实时守护Clash 进程，如果进程丢失则会自动实时重新拉起进程。</p>
																	<p style="color:gold; margin-top: 8px">注意：Clash本身运行稳定，通常不必开启该功能。</p>
																</div>
															</td>
														</tr>

														<tr style="display:none;">
															<th >自定义检查时间</th>
															<td colspan="2">
																<div class="SimpleNote" id="head_illustrate">
																	<input id="merlinclash_watchdog_delay_time" maxlength="2" class="input_6_table" value="1" ><span>&nbsp;分钟</span>
																	<input type="button" id="merlinclash_clash_watchdog_save" class="ks_btn" style="vertical-align: middle; cursor:pointer;" onclick="clash_watchdog_save();" value="保存设置" />
																	<script>
																		$("#merlinclash_watchdog_delay_time").on("keyup",function(){
																			$(this).val($(this).val().replace(/[^0-9]+/,''));
																			if($(this).val().length == 1){
																				$(this).val() == '0' ? $(this).val('1') : $(this).val();
																			}
																		});
																	</script>
																</div>
															</td>
														</tr>
													</table>
												</div>
												<!--Merlin Clash透明代理-->
												<div id="noipt" style="margin:-1px 0px 0px 0px;">
													<table style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >
														<thead>
															<tr>
																<td colspan="2">关闭透明代理 | <em style="color: gold">关闭后只能通过http/socks连接</em></td>
															</tr>
														</thead>
														<tr>
															<th>关闭透明代理</th>
															<td colspan="2">
																<div class="switch_field" style="display:table-cell;float: left;">
																	<label for="merlinclash_closeproxy">
																		<input id="merlinclash_closeproxy" type="checkbox" name="closeproxy" class="switch" style="display: none;">
																		<div class="switch_container" >
																			<div class="switch_bar"></div>
																			<div class="switch_circle transition_style">
																				<div></div>
																			</div>
																		</div>
																	</label>
																</div>
															</td>
														</tr>
													</table>
												</div>
												<!--Merlin Clash启动参数-->
												<div id="merlinclash-autodelay" style="margin:-1px 0px 0px 0px;">
													<table style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >
														<thead>
															<tr>
																<td colspan="2">启动参数</td>
															</tr>
														</thead>
														<tr>
															<th><a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(20)">开机自启推迟时间</a></th>
															<td colspan="2">
																<div class="SimpleNote" id="head_illustrate">
																	<input id="merlinclash_auto_delay_time" maxlength="3" class="input_6_table" value="120" ><span>&nbsp;秒&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
																	<input id="merlinclash_auto_delay_cbox" type="checkbox" name="merlinclash_auto_delay_cbox"><span>&nbsp;勾选后提交生效</span>
																</div>
																<script>
																	$("#merlinclash_auto_delay_time").on("keyup",function(){
																		$(this).val($(this).val().replace(/[^0-9]+/,''));
																		if($(this).val().length == 1){
																			$(this).val() == '0' ? $(this).val('2') : $(this).val();
																		}
																	});
																	$("#merlinclash_auto_delay_time").on("keydown",function(){
																		$(this).val($(this).val().replace(/[^0-9]+/,''));
																		if($(this).val().length == 1){
																			$(this).val() == '0' ? $(this).val('2') : $(this).val();
																		}
																	});
																</script>
															</td>
														</tr>
														<!--启动日志检查重试次数-->
														<tr>
															<th><a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(13)">检查日志重试次数</a></th>
															<td colspan="2">
																<div class="SimpleNote" id="head_illustrate">
																	<input id="merlinclash_check_delay_time" maxlength="3" class="input_6_table" value="40" ><span>&nbsp;次&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;尝试次数需大于20次</span>
																	<input id="merlinclash_check_delay_cbox" type="hidden" name="merlinclash_check_delay_cbox"><!--<span>&nbsp;勾选后提交生效</span>-->
																</div>
																<script>
																	$("#merlinclash_check_delay_time").on("keyup",function(){
																		$(this).val($(this).val().replace(/[^0-9]+/,''));
																		if($(this).val().length == 1){
																			$(this).val() == 0 ? $(this).val('40') : $(this).val();
																		}
																	});
																	$("#merlinclash_check_delay_time").on("keydown",function(){
																		$(this).val($(this).val().replace(/[^0-9]+/,''));
																		if($(this).val().length == 1){
																			$(this).val() == 0 ? $(this).val('40') : $(this).val();
																		}
																	});
																</script>
															</td>
														</tr>
														<!--启动时简化日志-->
														<tr id="start_log">
															<th>启动时简化日志</th>
															<td colspan="2">
																<div class="switch_field" style="display:table-cell;float: left;">
																	<label for="merlinclash_startlog">
																		<input id="merlinclash_startlog" type="checkbox" name="cir" class="switch" style="display: none;">
																		<div class="switch_container" >
																			<div class="switch_bar"></div>
																			<div class="switch_circle transition_style">
																				<div></div>
																			</div>
																		</div>
																	</label>
																</div>
															</td>
														</tr>
																						<!--开启队列请求-->
																						<tr id="start_log">
																							<th>开启队列请求</th>
																							<td colspan="2">
																								<div class="switch_field" style="display:table-cell;float: left;">
																									<label for="merlinclash_queue_switch">
																										<input id="merlinclash_queue_switch" type="checkbox" name="cir" class="switch" style="display: none;">
																										<div class="switch_container" >
																											<div class="switch_bar"></div>
																											<div class="switch_circle transition_style">
																												<div></div>
																											</div>
																										</div>
																									</label>
																								</div>
																							</td>
																						</tr>
																						<!--使用Cron记录节点-->
																						<tr id="record_by_cron">
																							<th>使用定时脚本记录代理组状态</th>
																							<td colspan="2">
																								<div class="switch_field" style="display:table-cell;float: left;">
																									<label for="merlinclash_recordbycron">
																										<input id="merlinclash_recordbycron" type="checkbox" name="cir" class="switch" style="display: none;">
																										<div class="switch_container" >
																											<div class="switch_bar"></div>
																											<div class="switch_circle transition_style">
																												<div></div>
																											</div>
																										</div>
																									</label>
																								</div>
																							</td>
																						</tr>
																						<!--绕行大陆IP-->
																						<tr id="china_ip_route">
																							<th><a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(17)">大陆IP不经过Clash</a><span id="cirtag"></span></th>
																							<td colspan="2">
																								<div class="switch_field" style="display:table-cell;float: left;">
																									<label for="merlinclash_cirswitch">
																										<input id="merlinclash_cirswitch" type="checkbox" name="cir" class="switch" style="display: none;">
																										<div class="switch_container" >
																											<div class="switch_bar"></div>
																											<div class="switch_circle transition_style">
																												<div></div>
																											</div>
																										</div>
																									</label>
																								</div>
																							</td>
																						</tr>
																						<!--DNS-->
																						<tr id="dns_goclash">
																							<th>代理路由自身访问</th>
																							<td colspan="2">
																								<div class="switch_field" style="display:table-cell;float: left;">
																									<label for="merlinclash_dnsgoclash">
																										<input id="merlinclash_dnsgoclash" type="checkbox" name="dnsgoclash" class="switch" style="display: none;" onchange="markdisplay('merlinclash_dnsgoclash')">
																										<div class="switch_container" >
																											<div class="switch_bar"></div>
																											<div class="switch_circle transition_style">
																												<div></div>
																											</div>
																										</div>
																									</label>
																								</div>
																							</td>
																						</tr>
																						<tr id="mark_value">
																							<th>路由自身流量标记值</th>
																							<td colspan="2">
																								<div class="SimpleNote" id="head_illustrate">
																									<input onkeyup="this.value=this.value.replace(/[^1-9]+/,'0')" id="merlinclash_cus_routingmark" maxlength="5" class="input_6_table" value="255" >
																									<em style="color: gold;">(默认值：255。不懂勿动！)</em>
																								</div>
																							</td>
																						</tr>
																						<!--清除自定义DNS-->
																						<tr id="dns_clear">
																							<th>清除路由自定义DNS</th>
																							<td colspan="2">
																								<div class="switch_field" style="display:table-cell;float: left;">
																									<label for="merlinclash_dnsclear">
																										<input id="merlinclash_dnsclear" type="checkbox" name="dnsclear" class="switch" style="display: none;">
																										<div class="switch_container" >
																											<div class="switch_bar"></div>
																											<div class="switch_circle transition_style">
																												<div></div>
																											</div>
																										</div>
																									</label>
																								</div>
																							</td>
																						</tr>
																						<tr id="mix_port">
																							<th>开启http/socks代理端口</th>
																							<td colspan="2">
																								<div class="switch_field" style="display:table-cell;float: left;">
																									<label for="merlinclash_mixport_enable">
																										<input id="merlinclash_mixport_enable" type="checkbox" name="mixport" class="switch" style="display: none;">
																										<div class="switch_container"  onclick="mixport_save()" href="javascript:void(0);">
																											<div class="switch_bar"></div>
																											<div class="switch_circle transition_style">
																												<div></div>
																											</div>
																										</div>
																									</label>
																								</div>
																							</td>
																						</tr>
																					</table>
																					<table style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_switch_table">
																						<thead>
																							<tr>
																								<td colspan="2">【Meta核心专属功能】</td>
																							</tr>
																						</thead>
																						<!--预解析奈飞-->
																						<tr id="ena_sniffer">
																							<th>Sniffer域名嗅探 --<a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(29)"><em style="color: gold;">【Netfilx TV客户端建议开启】</em></a></th>
																							<td colspan="2">
																								<div class="switch_field" style="display:table-cell;float: left;">
																									<label for="merlinclash_sniffer">
																										<input id="merlinclash_sniffer" type="checkbox" name="sniffer" class="switch" style="display: none;">
																										<div class="switch_container" >
																											<div class="switch_bar"></div>
																											<div class="switch_circle transition_style">
																												<div></div>
																											</div>
																										</div>
																									</label>
																								</div>
																								<input type="button" id="merlinclash_clash_routerrules_open" class="ks_btn" style="vertical-align: middle; cursor:pointer;" onclick="open_sniffer();" value="内容编辑" />
																							</td>
																						</tr>
																						<!--预解析检查间隔-->
																						<tr>
																							<th>TCP连接并发 --<a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(30)"><em style="color: gold;">【说明】</em></a></th>
																							<td colspan="2">
																								<div class="switch_field" style="display:table-cell;float: left;">
																									<label for="merlinclash_tcp_concurrent">
																										<input id="merlinclash_tcp_concurrent" type="checkbox" name="tcp_concurrent" class="switch" style="display: none;">
																										<div class="switch_container" >
																											<div class="switch_bar"></div>
																											<div class="switch_circle transition_style">
																												<div></div>
																											</div>
																										</div>
																									</label>
																								</div>
																							</td>
																						</tr>
																					</table>
																				</div>
																				<!--Merlin Clash自定义参数-->
																				<div id="clash_cusport_area">
																					<table style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >
																						<thead>
																							<tr>
																								<td colspan="2">Merlin Clash&nbsp;&nbsp;自定义端口
																									<input id="merlinclash_custom_cbox" type="checkbox" name="merlinclash_custom_cbox" ><em style="color: gold;">勾选后提交生效</em>
																								</td>
																							</tr>
																						</thead>
																						<tr>
																							<th>port:</th>
																							<td colspan="2">
																								<div class="SimpleNote" id="head_illustrate">
																									<input onkeyup="this.value=this.value.replace(/[^1-9]+/,'0')" id="merlinclash_cus_port" maxlength="5" class="input_6_table" value="3333" >
																									<em style="color: gold;">(默认值：3333)</em>
																								</div>
																							</td>
																						</tr>
																						<tr>
																							<th>socks-port:</th>
																							<td colspan="2">
																								<div class="SimpleNote" id="head_illustrate">
																									<input onkeyup="this.value=this.value.replace(/[^1-9]+/,'0')" id="merlinclash_cus_socksport" maxlength="5" class="input_6_table" value="23456" >
																									<em style="color: gold;">(默认值：23456)</em>
																								</div>
																							</td>
																						</tr>
																						<tr>
																							<th>redir-port:</th>
																							<td colspan="2">
																								<div class="SimpleNote" id="head_illustrate">
																									<input onkeyup="this.value=this.value.replace(/[^1-9]+/,'0')" id="merlinclash_cus_redirsport" maxlength="5" class="input_6_table" value="23457" >
																									<em style="color: gold;">(默认值：23457)</em>
																								</div>
																							</td>
																						</tr>
																						<tr>
																							<th>tproxy-port:</th>
																							<td colspan="2">
																								<div class="SimpleNote" id="head_illustrate">
																									<input onkeyup="this.value=this.value.replace(/[^1-9]+/,'0')" id="merlinclash_cus_tproxyport" maxlength="5" class="input_6_table" value="23458" >
																									<em style="color: gold;">(默认值：23458)</em>
																								</div>
																							</td>
																						</tr>
																						<tr>
																							<th>dns监听端口:</th>
																							<td colspan="2">
																								<div class="SimpleNote" id="head_illustrate">
																									<input onkeyup="this.value=this.value.replace(/[^1-9]+/,'0')" id="merlinclash_cus_dnslistenport" maxlength="5" class="input_6_table" value="23453" >
																									<em style="color: gold;">(默认值：23453)</em>
																								</div>
																							</td>
																						</tr>
																						<tr>
																							<th>管理面板访问端口:</th>
																							<td colspan="2">
																								<div class="SimpleNote" id="head_illustrate">
																									<input onkeyup="this.value=this.value.replace(/[^1-9]+/,'0')" id="merlinclash_cus_dashboardport" maxlength="5" class="input_6_table" value="9990" >
																									<em style="color: gold;">(默认值：9990)</em>
																								</div>
																							</td>
																						</tr>
																					</table>
																				</div>
																				<!--测速延迟容差设定-->
																				<div id="merlinclash-urltestTolerance" style="margin:-1px 0px 0px 0px;">
																					<table style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >
																						<thead>
																							<tr>
																								<td colspan="2">自动测Ping值设置 <a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(16)"><em style="color: gold;">【说明】</em></a></td>
																							</tr>
																						</thead>
																						<tr>
																							<th>自定义测速时间值(单位:秒)</th>
																							<td colspan="2">
																								<div class="SimpleNote" id="head_illustrate">
																									<select id="merlinclash_intervalsel" style="width:60px;margin:0px 0px 0px 2px;text-align:left;padding-left: 0px;" class="input_option">
																										<option value="60">60</option>
																										<option value="120">120</option>
																										<option value="180">180</option>
																										<option value="240">240</option>
																										<option value="300" selected>300</option>
																										<option value="360">360</option>
																										<option value="420">420</option>
																										<option value="480">480</option>
																										<option value="540">540</option>
																										<option value="600">600</option>
																									</select>
																									<input id="merlinclash_interval_cbox" type="checkbox" name="merlinclash_interval_cbox"><span>&nbsp;勾选后提交生效</span>
																								</div>
																							</td>
																						</tr>
																						<tr>
																							<th>自定义容差值(单位:毫秒)</th>
																							<td colspan="2">
																								<div class="SimpleNote" id="head_illustrate">
																									<select id="merlinclash_urltestTolerancesel" style="width:60px;margin:0px 0px 0px 2px;text-align:left;padding-left: 0px;" class="input_option">
																										<option value="100">100</option>
																										<option value="200">200</option>
																										<option value="300">300</option>
																										<option value="500">500</option>
																										<option value="1000">1000</option>
																									</select>
																									<input id="merlinclash_urltestTolerance_cbox" type="checkbox" name="merlinclash_urltestTolerance_cbox"><span>&nbsp;勾选后提交生效</span>
																								</div>
																							</td>
																						</tr>
																					</table>
																				</div>
																				<div id="merlinclash-dashboard" style="margin:-1px 0px 0px 0px;">
																					<table style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
																						<thead>
																							<tr>
																								<td colspan="2">管理面板设定 -- <em style="color: gold;">【开启面板公网访问请设置复杂密码】</em></td>
																							</tr>
																						</thead>
																						<tr id="dashboard">
																							<th>开启管理面板公网访问</th>
																							<td colspan="2">
																								<div class="switch_field" style="display:table-cell;float: left;">
																									<label for="merlinclash_dashboardswitch">
																										<input id="merlinclash_dashboardswitch" type="checkbox" name="dashboard" class="switch" style="display: none;">
																										<div class="switch_container" >
																											<div class="switch_bar"></div>
																											<div class="switch_circle transition_style">
																												<div></div>
																											</div>
																										</div>
																									</label>
																								</div>
																							</td>
																						</tr>
																						<tr>
																							<th>管理面板密码</th>
																							<td colspan="2">
																								<div class="SimpleNote" id="head_illustrate">
																									<input onkeyup="value=value.replace(/[^a-zA-Z0-9]/g,'')" id="merlinclash_dashboard_secret" class="input_15_table" placeholder="">
																								</div>
																							</td>
																						</tr>
																						</table>
																					</div>
																					<div id="tproxy" style="margin:-1px 0px 0px 0px;">
																						<table style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >
																							<thead>
																								<tr>
																									<td colspan="2">Tproxy转发&nbsp;|&nbsp;IPV6模式</td>
																								</tr>
																							</thead>
																							<tr id="Tproxy_plan">
																								<th><a class="hintstyle" >Tproxy模式</a></th>
																								<td colspan="2">
																									<label for="merlinclash_tproxymode">
																										<input id="merlinclash_tproxymode" type="radio" name="tproxymode" value="closed" checked="checked">默认:关闭
																										<input id="merlinclash_tproxymode" type="radio" name="tproxymode" value="tcp">仅开启TCP转发
																										<input id="merlinclash_tproxymode" type="radio" name="tproxymode" value="udp">仅开启UDP转发
																										<input id="merlinclash_tproxymode" type="radio" name="tproxymode" value="tcpudp">同时开启TCP&UDP
																									</label>
																									<p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1.默认为关闭</p>
																									<p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2.使用tproxy开启TCP转发实现透明代理</p>
																									<p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;3.使用tproxy开启UDP转发，类似【科学上网】的游戏模式</p>
																									<p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4.使用tproxy开启TCP,UDP转发做透明代理</p>
																								</td>
																							</tr>
																							<tr id="clash_ipv6" style="height: 30px;" >
																								<th>IPv6代理 <a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(24)"><em style="color: gold;"> - 不兼容护娃狂魔</em></a></th>
																								<td colspan="2">
																									<div class="switch_field" style="display:table-cell;float: left;">
																										<label for="merlinclash_ipv6switch">
																											<input id="merlinclash_ipv6switch" type="checkbox" name="ipv6" class="switch" style="display: none;">
																											<div class="switch_container" >
																												<div class="switch_bar"></div>
																												<div class="switch_circle transition_style">
																													<div></div>
																												</div>
																											</div>
																										</label>
																									</div>
																									<div style="line-height: 30px;"><p>需要运行在TPROXY-TCP或TPROXY-TCP&UDP模式下</p>
																									</div>
																								</td>
																							</tr>
																						</table>
																					</div>				
																				</div>
																				
											<!--附加功能-->
											<div id="tablet_4" style="display: none;">
												<div id="merlinclash-content-additional" style="margin:-1px 0px 0px 0px;">
													<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_switch_table">
														<thead>
															<tr>
																<td colspan="2">功能显示开关</td>
															</tr>
														</thead>
														<tr style="height: 30px;">
															<th>标签页</th>
															<td colspan="2">
																<div style="display:table-cell;float: left;text-align: center;text-align: center;line-height: 30px;">【自定规则】</div>
																<div class="switch_field" style="display:table-cell;float: left;">
																	<label for="merlinclash_check_aclrule">
																		<input id="merlinclash_check_aclrule" class="switch" type="checkbox" style="display: none;" name="aclrule_check" onchange="functioncheck('merlinclash_check_aclrule')">
																		<div class="switch_container" >
																			<div class="switch_bar"></div>
																			<div class="switch_circle transition_style">
																				<div></div>
																			</div>
																		</div>
																	</label>
																</div>
																<div style="display:table-cell;float: left;text-align: center;text-align: center;line-height: 30px;">【访问控制】</div>
																<div id="merlinclash_check_control_switch" class="switch_field" style="display:table-cell;float: left;">
																	<label for="merlinclash_check_controllist">
																		<input id="merlinclash_check_controllist" class="switch" type="checkbox" style="display: none;" name="controllist_check" onchange="functioncheck('merlinclash_check_controllist')">
																		<div class="switch_container" >
																			<div class="switch_bar"></div>
																			<div class="switch_circle transition_style">
																				<div></div>
																			</div>
																		</div>
																	</label>
																</div>
																<div style="display:table-cell;float: left;text-align: center;text-align: center;line-height: 30px;">【DlerCloud登陆】</div>
																<div class="switch_field" style="display:table-cell;float: left;">
																	<label for="merlinclash_check_dlercloud">
																		<input id="merlinclash_check_dlercloud" class="switch" type="checkbox" style="display: none;" name="dlercloud_check" onchange="functioncheck('merlinclash_check_dlercloud')">
																		<div class="switch_container" >
																			<div class="switch_bar"></div>
																			<div class="switch_circle transition_style">
																				<div></div>
																			</div>
																		</div>
																	</label>
																</div>
															</td>
														</tr>
														<tr style="height: 30px;">
															<th>配置文件</th>
															<td colspan="2">
																<div style="display:table-cell;float: left;text-align: center;text-align: center;line-height: 30px;">【导入Clash】</div>
																<div class="switch_field" style="display:table-cell;float: left;">
																	<label for="merlinclash_check_clashimport">
																		<input id="merlinclash_check_clashimport" class="switch" type="checkbox" style="display: none;" name="clashimport_check" onchange="functioncheck('merlinclash_check_clashimport')">
																		<div class="switch_container" >
																			<div class="switch_bar"></div>
																			<div class="switch_circle transition_style">
																				<div></div>
																			</div>
																		</div>
																	</label>
																</div>
																<div style="display:table-cell;float: left;text-align: center;text-align: center;line-height: 30px;">【SC本地转换】</div>
																<div class="switch_field" style="display:table-cell;float: left;">
																	<label for="merlinclash_check_sclocal">
																		<input id="merlinclash_check_sclocal" class="switch" type="checkbox" style="display: none;" name="sclocal_check" onchange="functioncheck('merlinclash_check_sclocal')">
																		<div class="switch_container" >
																			<div class="switch_bar"></div>
																			<div class="switch_circle transition_style">
																				<div></div>
																			</div>
																		</div>
																	</label>
																</div>
																<div style="display:table-cell;float: left;text-align: center;text-align: center;line-height: 30px;">【Yaml下载】</div>
																<div class="switch_field" style="display:table-cell;float: left;">
																	<label for="merlinclash_check_yamldown">
																		<input id="merlinclash_check_yamldown" class="switch" type="checkbox" style="display: none;" name="yamldown_check" onchange="functioncheck('merlinclash_check_yamldown')">
																		<div class="switch_container" >
																			<div class="switch_bar"></div>
																			<div class="switch_circle transition_style">
																				<div></div>
																			</div>
																		</div>
																	</label>
																</div>																
															</td>
														</tr>
														<tr style="height: 30px;">
															<th>自定规则</th>
															<td colspan="2">
																<div style="display:table-cell;float: left;text-align: center;text-align: center;line-height: 30px;">【转发白名单】</div>
																<div class="switch_field" style="display:table-cell;float: left;">
																	<label for="merlinclash_check_ipsetproxy">
																		<input id="merlinclash_check_ipsetproxy" class="switch" type="checkbox" style="display: none;" name="ipsetproxy_check" onchange="functioncheck('merlinclash_check_ipsetproxy')">
																		<div class="switch_container" >
																			<div class="switch_bar"></div>
																			<div class="switch_circle transition_style">
																				<div></div>
																			</div>
																		</div>
																	</label>
																</div>
																<div style="display:table-cell;float: left;text-align: center;text-align: center;line-height: 30px;">【转发黑名单】</div>
																<div class="switch_field" style="display:table-cell;float: left;">
																	<label for="merlinclash_check_ipsetproxyarround">
																		<input id="merlinclash_check_ipsetproxyarround" class="switch" type="checkbox" style="display: none;" name="ipsetproxyarround_check" onchange="functioncheck('merlinclash_check_ipsetproxyarround')">
																		<div class="switch_container" >
																			<div class="switch_bar"></div>
																			<div class="switch_circle transition_style">
																				<div></div>
																			</div>
																		</div>
																	</label>
																</div>
															</td>
														</tr>
														<tr style="height: 30px;">
															<th>附加功能</th>
															<td colspan="2">
																<div style="display:table-cell;float: left;text-align: center;text-align: center;line-height: 30px;">【Dns编辑】&nbsp;&nbsp;&nbsp;</div>
																<div class="switch_field" style="display:table-cell;float: left;">
																	<label for="merlinclash_check_cdns">
																		<input id="merlinclash_check_cdns" class="switch" type="checkbox" style="display: none;" name="cdns_check" onchange="functioncheck('merlinclash_check_cdns')">
																		<div class="switch_container" >
																			<div class="switch_bar"></div>
																			<div class="switch_circle transition_style">
																				<div></div>
																			</div>
																		</div>
																	</label>
																</div>
																<div style="display:table-cell;float: left;text-align: center;text-align: center;line-height: 30px;">&nbsp;【Hosts编辑】</div>
																<div class="switch_field" style="display:table-cell;float: left;">
																	<label for="merlinclash_check_chost">
																		<input id="merlinclash_check_chost" class="switch" type="checkbox" style="display: none;" name="cdns_check" onchange="functioncheck('merlinclash_check_chost')">
																		<div class="switch_container" >
																			<div class="switch_bar"></div>
																			<div class="switch_circle transition_style">
																				<div></div>
																			</div>
																		</div>
																	</label>
																</div>
															</td>
														</tr>
														<tr style="height: 30px;">
															<th>高级模式</th>
															<td colspan="2">
																<div style="display:table-cell;float: left;text-align: center;text-align: center;line-height: 30px;">【透明代理】</div>
																<div class="switch_field" style="display:table-cell;float: left;">
																	<label for="merlinclash_check_noipt">
																		<input id="merlinclash_check_noipt" class="switch" type="checkbox" style="display: none;" name="noipt_check" onchange="functioncheck('merlinclash_check_noipt')">
																		<div class="switch_container" >
																			<div class="switch_bar"></div>
																			<div class="switch_circle transition_style">
																				<div></div>
																			</div>
																		</div>
																	</label>
																</div>
																<div style="display:table-cell;float: left;text-align: center;text-align: center;line-height: 30px;">&nbsp;&nbsp;&nbsp;&nbsp;【自定义端口】</div>
																<div class="switch_field" style="display:table-cell;float: left;">
																	<label for="merlinclash_check_cusport">
																		<input id="merlinclash_check_cusport" class="switch" type="checkbox" style="display: none;" name="cusport_check" onchange="functioncheck('merlinclash_check_cusport')">
																		<div class="switch_container" >
																			<div class="switch_bar"></div>
																			<div class="switch_circle transition_style">
																				<div></div>
																			</div>
																		</div>
																	</label>
																</div>
																<div id="tproxy_show" style="display:table-cell;float: left;text-align: center;text-align: center;line-height: 30px;">&nbsp;&nbsp;【TPROXY选项】</div>
																<div id="tproxy_showcbox" class="switch_field" style="display:table-cell;float: left;">
																	<label for="merlinclash_check_tproxy">
																		<input id="merlinclash_check_tproxy" class="switch" type="checkbox" style="display: none;" name="tproxy_check" onchange="functioncheck('merlinclash_check_tproxy')">
																		<div class="switch_container" >
																			<div class="switch_bar"></div>
																			<div class="switch_circle transition_style">
																				<div></div>
																			</div>
																		</div>
																	</label>
																</div>
													</td>
												</tr>
												<tr style="height: 30px;">
													<th>应用设置</th>
													<td colspan="2">
														<div class="switch_field" style="display:table-cell;float: left;">
															<label for="merlinclash_check_apply">
																<input class="button_gen" id="apply_button" type="button" onclick="functioncheck(false,true)" value="提交应用">
															</label>
														</div>
													</td>
												</tr>
											</table>
											<table style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_switch_table">
												<thead>
													<tr>
														<td colspan="2">备份&还原 <a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(22)"><em style="color:gold">【备份内容说明】</em></a></td>
													</tr>
												</thead>
												<tr>
													<th>一键备份</th>
													<td colspan="2">
														<a type="button" style="vertical-align: middle; cursor:pointer;" id="clashdata-btn-download" class="ks_btn" onclick="down_clashdata(1)" >下载备份</a>
													</td>
												</tr>
												<tr>
													<th>一键还原</th>
													<td colspan="2">
														<div class="SimpleNote" style="display:table-cell;float: left; height: 110px; line-height: 110px; margin:-40px 0;">
															<input type="file" style="width: 200px;margin: 0,0,0,0px;" id="clashdata" size="50" name="file"/>
															<span id="clashdata_info" style="display:none;">完成</span>
															<a type="button" style="vertical-align: middle; cursor:pointer;" id="clashdata-btn-upload" class="ks_btn" onclick="upload_clashdata()" >恢复备份</a>
														</div>
													</td>
												</tr>
											</table>
											<table style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_switch_table">
												<thead>
													<tr>
														<td colspan="2">文件下载与更新</td>
													</tr>
												</thead>
												<tr>
													<th><a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(21)">GeoIP 数据库</a></th>
													<td colspan="2">
														<div class="SimpleNote" id="head_illustrate">
															<p>在线更新 Clash 使用的GeoIP数据库</p>
															<p style="color:#FC0">注：更新不会对比新旧版本号，重复点击会重复升级！（1个月左右更新一次即可）</p>
															<p>&nbsp;</p>
															<select id="merlinclash_geoip_type" style="width:120px;margin:0px 0px 0px 2px;text-align:left;padding-left: 0px;" class="input_option">
																<!--<option value="maxmind">MaxMind-4M版</option>-->
																<option value="ipip">ipip-4M版</option>
																<option value="Hackl0us">Hackl0us-100kb版</option>
																<option value="Loyalsoldier">Loyalsoldier增强版</option>
																<option value="Loyalsoldier300">LoyalS-300kb版</option>
																<option value="Mcore_LCN">M核专用：Meta-GeositeCN-200K</option>
																<option value="Mcore_ALL">M核专用：Meta-Geosite-3M</option>
																<option value="Mcore_FULL">M核专用：Loyals—GeoSite-5M</option>
															</select>
															<a type="button" class="ks_btn" style="cursor:pointer" onclick="geoip_update(5)">更新GeoIP数据库</a>
															<span id="geoip_updata_date">上次更新时间：</span>
														</div>
													</td>
												</tr>
												<tr>
													<th>大陆IP白名单</th>
													<td colspan="2">
														<div class="SimpleNote" id="head_illustrate">
															<p>大陆IP白名单 使用由Fernvenue提供的 <a href="https://github.com/fernvenue/chn-cidr-list" target="_blank"><u>CHN CIDR list</u></a>规则</p>
															<p style="color:#FC0">注：更新不会对比新旧版本号，重复点击会重复升级！（1个月左右更新一次即可）</p>
															<p>&nbsp;</p>
															<a type="button" class="ks_btn" style="cursor:pointer" onclick="chnroute_update(25)">更新大陆白名单规则</a>
															<span id="chnroute_updata_date">上次更新时间：</span>
														</div>
													</td>
												</tr>
												<!-- <tr>
													<th>Clash二进制替换 --在线更换</th>
													<td colspan="2">
														<div class="SimpleNote" id="head_illustrate">
															<select id="merlinclash_clashbinarysel"  name="clashbinarysel" dataType="Notnull" class="input_option" style="width: 200px;"></select>
															<a type="button" class="ks_btn" style="cursor:pointer" onclick="clash_getversion(10)">获取远程版本文件</a>
															<a type="button" class="ks_btn" style="cursor:pointer" onclick="clash_replace(11)">替换clash二进制</a>
														</div>
													</td>
												</tr> -->
												<thead>
													<tr>
														<td colspan="2">二进制上传下载与规则更新</td>
													</tr>
												</thead>
												<tr>
													<th>二进制下载</th>
													<td colspan="2">
														<p>
															<a style="color:#FC0" target="_blank" href="https://github.com/MetaCubeX/Clash.Meta/releases">【<u>Mihomo</u>】</a>
															<a style="color:#FC0" target="_blank" href="https://github.com/MetaCubeX/subconverter/releases">【<u>Subconverter-vless</u>】</a>
														</p>
													</td>
												</tr>
												<tr>
													<th>二进制上传</th>
													<td colspan="2">
														<div class="SimpleNote" style="display:table-cell;float: left; height: 110px; line-height: 110px; margin:-40px 0;">
															<select id="merlinclash_binary_type" style="width:80px;margin:0px 0px 0px 2px;text-align:left;padding-left: 0px;" class="input_option">
																<option value="clash">Mihomo</option>
																<option id="subc_show" value="subconverter">Subconverter</option>
																</select>
																<input type="file" id="clashbinary" size="50" name="file"/>
																<span id="clashbinary_upload" style="display:none;">完成</span>
																<a type="button" style="vertical-align: middle; cursor:pointer;" id="clashbinary-btn-upload" class="ks_btn" onclick="upload_clashbinary()" >上传二进制</a>
															</div>
														</td>
													</tr>
													<tr id="up_scrule">
														<th>SubConverter&nbsp;&nbsp;规则更新</th>
														<td colspan="2">
															<div class="SimpleNote" id="head_illustrate">
																<a type="button" id="updatescBtn" class="ks_btn" style="cursor:pointer" onclick="sc_update(18)">&nbsp;&nbsp;更新规则&nbsp;&nbsp;</a>
																<span id="sc_version">&nbsp;&nbsp;当前版本：</span>
															</div>
														</td>
													</tr>
												</table>
												<div id="clash_dns_area">
													<table style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_dnsfiles_table">
														<thead>
															<tr>
																<td colspan="2">DNS&nbsp;&nbsp;编辑 -- <em style="color: gold;">【不懂勿动！编辑完成后点击“修改提交”保存，下次启动后生效】|【开启编辑：<input id="merlinclash_dnsedit_check" class="barcodeSavePrint" type="checkbox" name="dnsedit_check" >】</em></td>
															</tr>
															<script>
																$(function () {
																	$(".barcodeSavePrint").click(function () {
																		if (this.checked==true){
																			document.getElementById("merlinclash_dns_edit_content1").readOnly = false
																		}else{
																			document.getElementById("merlinclash_dns_edit_content1").readOnly = true
																		}
																	})
																})
															</script>
														</thead>
													</table>
													<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_dnsfiles_content_table">
														<tr id="dns_plan_edit">
															<th>DNS内容编辑</th>
															<td colspan="2">
																<label for="merlinclash_dnsplan_edit">
																	<input id="merlinclash_dnsplan_edit" type="radio" name="dnsplan_edit" value="redirhost" checked="checked">Redir-Host
																	<input id="merlinclash_dnsplan_edit" type="radio" name="dnsplan_edit" value="fakeip">Fake-ip
																	<!-- <input id="merlinclash_dnsplan_edit" type="radio" name="dnsplan_edit" value="rhbypass">RHbypass -->
																	<input class="ks_btn" type="button" onclick="dnsfilechange()" value="修改提交">
																</label>
																<script>
																	$("[name='dnsplan_edit']").on("change",
																		function (e) {
																			var dns_tag=$(e.target).val();
																			get_dnsyaml(dns_tag);
																		}
																		);
																	</script>
																</td>
															</tr>
														</table>
														<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
															<div id="merlinclash_dns_edit_content" class="mc_outline" style="margin-top:-1px;overflow:hidden;">
																<textarea rows="7" wrap="on" id="merlinclash_dns_edit_content1" name="dns_edit_content1" style="margin: 0px; width: 709px; height: 300px; resize: none;" readonly="true"></textarea>
															</div>
														</table>
													</div>
													<div id="clash_host_area">
														<!--自定义HOST-->
														<table style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
															<thead>
																<tr>
																	<td colspan="2">自定义Hosts<a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(11)"><em>【说明】</a></em>&nbsp;<em style="color:gold;">【不懂勿动！编辑完成后点击“修改提交”保存，下次启动后生效】|【开启编辑：<input id="merlinclash_hostedit_check" class="hostenableedit" type="checkbox" name="hostedit_check" >】</em></td>
																</tr>
															</thead>
															<script>
																$(function () {
																	$(".hostenableedit").click(function () {
																		if (this.checked==true){
																			document.getElementById("merlinclash_host_content1").readOnly = false
																		}else{
																			document.getElementById("merlinclash_host_content1").readOnly = true
																		}
																	})
																})
															</script>
															<tr id="hostselect">
																<th>HOST文件选择</th>
																<td colspan="2">
																	<select id="merlinclash_hostsel"  name="hostsel" dataType="Notnull" msg="HOST文件不能为空!" class="input_option" ></select>
																	<a type="button" style="vertical-align: middle;" class="ks_btn" style="cursor:pointer" onclick="hostchange()" href="javascript:void(0);" >&nbsp;&nbsp;修改提交&nbsp;&nbsp;</a>
																	<a type="button" style="vertical-align: middle;" class="ks_btn" style="cursor:pointer" onclick="download_host()" href="javascript:void(0);">&nbsp;&nbsp;下载HOST&nbsp;&nbsp;</a>
																	<a type="button" style="vertical-align: middle;" class="ks_btn" style="cursor:pointer" onclick="del_host_sel()" href="javascript:void(0);" >&nbsp;&nbsp;删除HOST&nbsp;&nbsp;</a>
																</td>
																<script>
																	$("[name='hostsel']").on("change",
																		function (e) {
																			var host_tag=$(e.target).val();
																			get_host(host_tag);
																		}
																		);
																	</script>
																</tr>
															</table>
															<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
																<div id="merlinclash_host_content" class="mc_outline" style="margin-top:-1px;overflow:hidden;">
																	<textarea rows="7" wrap="on" id="merlinclash_host_content1" style="margin: 0px; width: 709px; height: 300px; resize: none; " readonly="true"></textarea>
																</div>
																<tr>
																	<th>上传HOST文件</th>
																	<td colspan="2">
																		<div class="SimpleNote" style="display:table-cell;float: left; height: 110px; line-height: 110px; margin:-40px 0;">
																			<input type="file" id="clashhost" size="50" name="file"/>
																			<span id="clashhost_upload" style="display:none;">完成</span>
																			<a type="button" style="vertical-align: middle; cursor:pointer;" id="clashhost-btn-upload" class="ks_btn" onclick="upload_clashhost()" >上传HOST文件</a>
																		</div>
																	</td>
																</tr>
															</table>
														</div>
													</div>
												</div>
												
										<!--当前配置-->
										<div id="tablet_6" style="display: none;">
											<div id="yaml_content" class="mc_outline" style="height: 650px;">
												<textarea class="sbar" cols="63" rows="36" wrap="on" readonly="readonly" id="yaml_content1" style="margin: 0px; width: 709px; height: 645px; resize: none;"></textarea>
											</div>
										</div>
										<!--dlercloud-->
										<div id="tablet_10" style="display: none;">
											<div id="dlercloud_login" style="height: 150px;">
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >
													<thead>
														<tr>
															<td colspan="2">Dler Cloud登陆</td>
														</tr>
													</thead>
													<tr id="clash_loginname">
														<th>用户名</th>
														<td>
															<div style="display:table-cell;float: left;margin-left:0px;">
																<input id="merlinclash_dc_name" style="color: #FFFFFF; width: 300px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;" placeholder="">
															</div>
														</td>
													</tr>
													<tr id="clash_loginpasswd">
														<th>密码</th>
														<td>
															<div style="display:table-cell;float: left;margin-left:0px;">
																<input id="merlinclash_dc_passwd" type="password" style="color: #FFFFFF; width: 300px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;" placeholder="">
															</div>
														</td>
													</tr>
													<tr id="clash_loginbtn">
														<th>登陆</th>
														<td>
															<div style="display:table-cell;float: left;margin-left:0px;">
																<a type="button" style="vertical-align: middle; margin:-10px 10px;" class="ks_btn" style="cursor:pointer" onclick="dc_login()" href="javascript:void(0);">&nbsp;&nbsp;登陆&nbsp;&nbsp;</a>
																&nbsp;&nbsp;
																<a type="button" style="vertical-align: middle; margin:-10px 10px;" class="ks_btn" style="cursor:pointer" href="https://dlercloud.com/auth/login" target="_blank">&nbsp;&nbsp;官网&nbsp;&nbsp;</a>
															</div>
														</td>
													</tr>
												</table>
											</div>
											<div id="dlercloud_content" style="width:750px; height: 650px;">
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >
													<thead>
														<tr>
															<td colspan="2">Dler Cloud信息</td>
														</tr>
													</thead>
													<tr id="clash_loginname">
														<th>用户名</th>
														<td>
															<div style="display:table-cell;float: left;margin-left:0px;">
																<span id="dc_name"></span>
																<span id="dc_token" style="display: none;"></span>
																<a type="button" style="vertical-align: middle; margin:-10px 10px;" class="ks_btn" style="cursor:pointer" onclick="dc_logout()" href="javascript:void(0);">&nbsp;&nbsp;退出&nbsp;&nbsp;</a>
															</div>
														</td>
													</tr>
													<tr id="clash_money">
														<th>余额</th>
														<td>
															<div style="display:table-cell;float: left;margin-left:0px;">
																<span id="dc_money"></span>
															</div>
														</td>
													</tr>
													<tr id="clash_affmoney">
														<th>返利</th>
														<td>
															<div style="display:table-cell;float: left;margin-left:0px;">
																<span id="dc_affmoney"></span>
															</div>
														</td>
													</tr>
													<tr id="clash_integral">
														<th>积分</th>
														<td>
															<div style="display:table-cell;float: left;margin-left:0px;">
																<span id="dc_integral"></span>
															</div>
														</td>
													</tr>
													<tr id="clash_plan">
														<th>当前套餐</th>
														<td>
															<div style="display:table-cell;float: left;margin-left:0px;">
																<span id="dc_plan"></span>
															</div>
														</td>
													</tr>
													<tr id="clash_plantime">
														<th>到期时间</th>
														<td>
															<div style="display:table-cell;float: left;margin-left:0px;">
																<span id="dc_plantime"></span>
															</div>
														</td>
													</tr>
													<tr id="clash_usedTraffic">
														<th>已用流量</th>
														<td>
															<div style="display:table-cell;float: left;margin-left:0px;">
																<span id="dc_usedTraffic"></span>
															</div>
														</td>
													</tr>
													<tr id="clash_unusedTraffic">
														<th>可用流量</th>
														<td>
															<div style="display:table-cell;float: left;margin-left:0px;">
																<span id="dc_unusedTraffic"></span>
															</div>
														</td>
													</tr>
												</table>
												<table style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >
													<thead>
														<tr>
															<td colspan="2">订阅相关 -- <em style="color: gold;">如重置过连接参数，需要退出重新登陆才可以订阅</em></td>
														</tr>
													</thead>
													<tr id="clash_ss">
														<th>SS节点</th>
														<td>
															<div style="display:table-cell;float: left;margin-left:0px;">
																<span id="dc_ss"></span>
																<a type="button" style="vertical-align: middle; margin:-10px 10px;" class="ks_btn" style="cursor:pointer" onclick="dc_ss_yaml(2)" href="javascript:void(0);">订阅</a>
															</div>
														</td>
													</tr>
													<tr id="clash_v2">
														<th>v2ray节点</th>
														<td>
															<div style="display:table-cell;float: left;margin-left:0px;">
																<span id="dc_v2"></span>
																<a type="button" style="vertical-align: middle; margin:-10px 10px;" class="ks_btn" style="cursor:pointer" onclick="dc_v2_yaml(2)" href="javascript:void(0);">订阅</a>
															</div>
														</td>
													</tr>
													<tr id="clash_trojan">
														<th>trojan节点</th>
														<td>
															<div style="display:table-cell;float: left;margin-left:0px;">
																<span id="dc_trojan"></span>
																<a type="button" style="vertical-align: middle; margin:-10px 10px;" class="ks_btn" style="cursor:pointer" onclick="dc_tj_yaml(2)" href="javascript:void(0);">订阅</a>
															</div>
														</td>
													</tr>
													<tr id="sc3in1">
														<th><br>SubConverter三合一转换
															<br>
															<br><em style="color: gold;">SS&nbsp;|&nbsp;SSR&nbsp;|&nbsp;V2ray订阅|&nbsp;Trojan订阅</em>
															<br><em style="color: gold;">内置ACL4SSR/MerlinClash专属规则</em>
															<br><em style="color: gold;">本地SubConverter进程转换</em>
														</th>
														<td>
															<div class="SimpleNote" style="display:table-cell;float: left; width: 400px;">
																<span>emoji:</span>
																<input id="merlinclash_dc_subconverter_emoji" type="checkbox" name="dc_subconverter_emoji" checked="checked">
																<span>启用udp:</span>
																<span id="merlinclash_dc_subconverter_udp" type="checkbox" name="dc_subconverter_udp">
																	<label>节点类型:</span>
																		<span id="merlinclash_dc_subconverter_append_type" type="checkbox" name="dc_subconverter_append_type">
																			<label>节点排序:</span>
																				<span id="merlinclash_dc_subconverter_sort" type="checkbox" name="dc_subconverter_sort">
																					<label>过滤非法节点:</span>
																						<span id="merlinclash_dc_subconverter_fdn" type="checkbox" name="dc_subconverter_fdn">
																							<br>
																							<span>跳过证书验证:</span>
																							<input id="merlinclash_dc_subconverter_scv" type="checkbox" name="dc_subconverter_scv">
																							<span>TCP Fast Open:</span>
																							<input id="merlinclash_dc_subconverter_tfo" type="checkbox" name="dc_subconverter_tfo">
																						</div>
																						<div class="SimpleNote" style="display:table-cell;float: left; width: 400px;">
																							<p><span>包含节点：</span>
																								<input id="merlinclash_dc_subconverter_include" class="input_25_table" style="width:320px" placeholder="&nbsp;筛选包含关键字的节点名，支持正则">
																							</p>
																							<br>
																							<p><span>排除节点：</span>
																								<input id="merlinclash_dc_subconverter_exclude" class="input_25_table" style="width:320px" placeholder="&nbsp;过滤包含关键字的节点名，支持正则">
																							</p>
																						</div>
																						<div class="SimpleNote" style="display:table-cell;float: left; height: 30px; line-height: 30px; ">
																							<select id="merlinclash_dc_clashtarget" style="width:75px;margin:0px 0px 0px 2px;text-align:left;padding-left: 0px;" class="input_option">
																								<option value="clash">clash新参数</option>
																								<option value="clashr">clashR新参数</option>
																							</select>
																							<select id="merlinclash_dc_acl4ssrsel" style="width:220px;margin:0px 0px 0px 2px;text-align:left;padding-left: 0px;" class="input_option">
																								<option value="ZHANG">Merlin Clash_常规规则</option>
																								<option value="ZHANG_NoAuto">Merlin Clash_常规无测速</option>
																								<option value="ZHANG_Media">Merlin Clash_多媒体全量</option>
																								<option value="ZHANG_Media_NoAuto">Merlin Clash_多媒体全量无测速</option>
																								<option value="ZHANG_Media_Area_UrlTest">Merlin Clash_多媒体全量分地区测速</option>
																								<option value="ZHANG_Media_Area_FallBack">Merlin Clash_多媒体全量分地区故障转移</option>
																								<option value="ACL4SSR_Online">Online默认版_分组比较全</option>
																								<option value="ACL4SSR_Online_AdblockPlus">AdblockPlus_更多去广告</option>
																								<option value="ACL4SSR_Online_NoAuto">NoAuto_无自动测速</option>
																								<option value="ACL4SSR_Online_NoReject">NoReject_无广告拦截规则</option>
																								<option value="ACL4SSR_Online_Mini">Mini_精简版</option>
																								<option value="ACL4SSR_Online_Mini_AdblockPlus">Mini_AdblockPlus_精简版更多去广告</option>
																								<option value="ACL4SSR_Online_Mini_NoAuto">Mini_NoAuto_精简版无自动测速</option>
																								<option value="ACL4SSR_Online_Mini_Fallback">Mini_Fallback_精简版带故障转移</option>
																								<option value="ACL4SSR_Online_Mini_MultiMode">Mini_MultiMode_精简版自动测速故障转移负载均衡</option>
																								<option value="ACL4SSR_Online_Full">Full全分组_重度用户使用</option>
																								<option value="ACL4SSR_Online_Full_NoAuto">Full全分组_无自动测速</option>
																								<option value="ACL4SSR_Online_Full_AdblockPlus">Full全分组_更多去广告</option>
																								<option value="ACL4SSR_Online_Full_Netflix">Full全分组_奈飞全量</option>
																								<option value="ACL4SSR_Online_Full_Google">Full全分组_谷歌细分</option>
																								<option value="ACL4SSR_Online_Full_MultiMode">Full全分组_多模式</option>
																								<option value="ACL4SSR_Online_Mini_MultiCountry">Full全分组_多国家地区</option>
																							</select>
																						</div>
														</td>
													</tr>
												</table>
												<div class="SimpleNote" style="margin-left:270px ; display:table-cell;float: left; height: 30px; line-height: 30px; ">
													<label style="color: gold;">远程配置：</label>
													<input id="merlinclash_dc_uploadiniurl" class="input_25_table" style="width:185px" placeholder="&nbsp;请输入文件URL地址">
													<input id="merlinclash_dc_customurl_cbox" type="checkbox" name="merlinclash_dc_customurl_cbox"><span>&nbsp;勾选使用</span>
													<a type="button" style="vertical-align: middle; margin:-10px 10px;" class="ks_btn" style="cursor:pointer" onclick="get_online_yaml4(21)" href="javascript:void(0);">&nbsp;&nbsp;开始转换&nbsp;&nbsp;</a>
												</div>
											</div>
										</div>
										<!--底部按钮-->
										<div class="apply_gen" id="loading_icon">
											<img id="loadingIcon" style="display:none;" src="/images/InternetScan.gif">
										</div>
										<div class="apply_gen">
											<input class="button_gen" id="delallowneracls_button" type="button" onclick="delallaclconfigs()" value="全部删除">
											<input class="button_gen" id="apply_button" type="button" onclick="apply()" value="保存&启动">
										</div>
									</td>
								</tr>
							</table>
						</div>
					</td>
				</tr>
			</table>
		</td>
		<td width="10" align="center" valign="top"></td>
	</tr>
</table>
<div id="footer"></div>
<div id="loadingMask" style="display: none; position: fixed; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0); z-index: 9999;">
	<p style="position: absolute; top: 2%; right: 0%; transform: translate(-50%, -50%); color: white;">加载中...</p>
</div>
</body>
</html> 
