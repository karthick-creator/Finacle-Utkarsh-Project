<%/*
------------------------------------------------------------------------------------------------
File Name			:	mis_codes_custom.jsp
Menu Name			:	HOAACLA
Start Date			:	05-02-2023
Description			:	Retail loans_180 - 
Author				:	Akash N
Called Scripts		:	
Modification History
-------------------------------------------------------------------------------------------------
S.No.	|	Date		|	Name					|	Description
-----		--------- 		----------------------		-----------------------------------------
 1		|	14-08-2025	|	Akash N					|	Base Version
-------------------------------------------------------------------------------------------------
*/
%>
<%@ include file="../commonInclude.jsp" %>
<%@ page import="FABCommon.SecurityInfo70"%>
<custom:getRepository/>
<%
ContextManager ARJspCurr =(ContextManager)session.getAttribute("CustomARJspCurr");
String templateFuncCode = (String)ARJspCurr.getInput("lasch.mode",null);
SecurityInfo70 securityInfo = (SecurityInfo70)session.getAttribute("FinUserInfo");
%>
<script language="javascript" src="../Renderer/javascripts/lists/<%=VRPKeys.getFile("showEmpSearcher.js",sProfileId)%>"></script>

<SCRIPT language="javascript" src="../Renderer/javascripts/<%=VRPKeys.getFile("common_functions.js",sProfileId)%>" > </SCRIPT>

<SCRIPT language="javascript" src="../../javascripts/common_functions.js" ></SCRIPT>




<script>
var BODDate= '<%= ParseValue.checkString((securityInfo.bodDate).substring(0,10))%>';
</script>
<script  language="javascript">

function mis_codes_post_ONLOAD(obj)
{
/*UTKARSH_REQUIREMENT_RETAIL_LOAN_218_start*/
   if((mopId == "HOAACLA")||(mopId == "HOAACMLA")||(mopId == "HOAACVLA")||(mopId == "HACMLA")||(mopId == "HOAACOD")||(mopId == "HOAACMOD")||(mopId == "HACM"))  
	{
                var label4 = document.getElementById('freeCode6');
                label4.parentNode.parentNode.cells[3].innerHTML='Business verticals';
		label4.parentNode.parentNode.cells[3].innerHTML=label4.parentNode.parentNode.cells[3].innerHTML + '&nbsp<font color="red" size = 3>*</font>';		

	}
/*UTKARSH_REQUIREMENT_RETAIL_LOAN_218_end*/
}

function mis_codes_pre_TAB_SWITCH(obj)
{

/*UTKARSH_REQUIREMENT_RETAIL_LOAN_218_start*/
 if((mopId == "HOAACLA")||(mopId == "HOAACMLA")||(mopId == "HOAACVLA")||(mopId == "HACMLA")||(mopId == "HOAACOD")||(mopId == "HOAACMOD")||(mopId == "HACM"))
        {
		var ObjForm = document.forms[0];
                if(fnIsNull(ObjForm.freeCode6.value))
                {
                        alert("Enter Business Vertical");
                        return false;
                }

        }
/*UTKARSH_REQUIREMENT_RETAIL_LOAN_218_end*/
		
}

</script>
