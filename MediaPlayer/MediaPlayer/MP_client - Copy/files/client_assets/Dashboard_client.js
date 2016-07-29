
$(function() {
    var count_elements = $("#tblLeftGridElements tr").length - 1;
    var lblResultsCount = $("span[id$='_lblResultsCount']");
    lblResultsCount.text(count_elements);

    var txb_search = $("input[id$='_txbSearchBox1']");
    var _hdnFolioID = $("input[id*='_hdnFolioID']");
    if (_hdnFolioID != null && _hdnFolioID.val() != null && _hdnFolioID.val().length > 0) {
        txb_search.val(_hdnFolioID.val());
    }
    
});
