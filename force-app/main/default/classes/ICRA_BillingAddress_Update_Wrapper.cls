global class ICRA_BillingAddress_Update_Wrapper {
	global class Data {
		global String billingStreet;
		global String billingCity;
		global String billingCountry;
		global String billingState;
		global String billingPostalCode;
		global String gstn;
		global String bvdId;
		global String billingAddress_ID;
        global String billingcurrency;
	}

	global List<Data> data;

	global static ICRA_BillingAddress_Update_Wrapper parse(String json) {
		return (ICRA_BillingAddress_Update_Wrapper) System.JSON.deserialize(json, ICRA_BillingAddress_Update_Wrapper.class);
	}
}