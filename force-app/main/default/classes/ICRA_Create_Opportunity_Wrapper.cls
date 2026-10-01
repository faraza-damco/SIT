global class ICRA_Create_Opportunity_Wrapper {
	global class Data {
		global String mandate_id;
		global String surveillance_id;
		global String account_id;
		global String instrument_category;
		global String trust_name;
		global String rated_vod;
		global String pr_date;
		global String date_of_communication;
		global String client_status;
	}

	global List<Data> data;

	global static ICRA_Create_Opportunity_Wrapper parse(String json) {
		return (ICRA_Create_Opportunity_Wrapper) System.JSON.deserialize(json, ICRA_Create_Opportunity_Wrapper.class);
	}
}