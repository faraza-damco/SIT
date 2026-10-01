global class ICRA_Opportunity_Update_Wrapper {
	global class Data {
		global String mandate_Id;
		global String sow_status;
        global String ratedEntity_BvD_ID;
        global String ratedEntity;
        global String pan_number;
        global String street;
        global String city;
        global String state;
        global String country;
        global String postalCode;
        global String pr_date;
        global String date_of_communication;
        global String date_of_non_acceptance_of_rating;
        global String analyst;
        global String sector_head;
        global String co_analyst;
        global String group_head;
        global String quality_analyst;
        global String scheme_trust;
        global String workItemNumber;
	}

	global List<Data> data;

	global static ICRA_Opportunity_Update_Wrapper parse(String json) {
		return (ICRA_Opportunity_Update_Wrapper) System.JSON.deserialize(json, ICRA_Opportunity_Update_Wrapper.class);
	}
}