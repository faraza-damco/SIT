global class ICRA_Account_Update_Wrapper {
	global List<Data> data;

	global class Data {
		global String sectorL3;
		global String sectorL5;
		global String sectorL1;
		global String sectorL2;
		global String sectorL4;
		global String orbis_id;
		global String bvd_id;
		global String sf_account_id;
		global String accountName;
		global String group_name;
		global String phone;
		global String website;
		global String constitution_type;
		global String md_text;
		global String cfo_text;
		global String pan_number;
		global String tan_number;
		//global String kyc_last_updated_date;
		global String lei_number;
		global String cin_number;
		//global String email_auditor;
		global String shippingCountry;
		global String shippingStreet;
		global String shippingCity;
		global String shippingState;
		global String shippingPostalCode;
        global String businessClassification;

	}

	global static ICRA_Account_Update_Wrapper parse(String json) {
		return (ICRA_Account_Update_Wrapper) System.JSON.deserialize(json, ICRA_Account_Update_Wrapper.class);
	}
}