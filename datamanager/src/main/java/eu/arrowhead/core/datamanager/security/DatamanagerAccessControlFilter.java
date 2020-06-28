package eu.arrowhead.core.datamanager.security;

import java.util.Map;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;

import eu.arrowhead.common.CommonConstants;
import eu.arrowhead.common.CoreCommonConstants;
import eu.arrowhead.common.dto.shared.SenML;
import eu.arrowhead.common.Utilities;
import eu.arrowhead.common.core.CoreSystem;
import eu.arrowhead.common.exception.AuthException;
import eu.arrowhead.common.security.CoreSystemAccessControlFilter;

@Component
@ConditionalOnProperty(name = CommonConstants.SERVER_SSL_ENABLED, matchIfMissing = true) 
public class DatamanagerAccessControlFilter extends CoreSystemAccessControlFilter {
	
	//=================================================================================================
        // members
        
	//=================================================================================================
	// assistant methods

	//-------------------------------------------------------------------------------------------------
	@Override
	protected void checkClientAuthorized(final String clientCN, final String method, final String requestTarget, final String requestJSON, final Map<String,String[]> queryParams) {
		super.checkClientAuthorized(clientCN, method, requestTarget, requestJSON, queryParams);

		final String cloudCN = getServerCloudCN();

		if (requestTarget.endsWith(CommonConstants.ECHO_URI)) {
      // Everybody in the local cloud can test the server => no further check is necessary
      return;
		} 

    // only the system named Sysname is allowed to write to <historian or proxy>/$SysName/$SrvName
    if (!method.toLowerCase().equals("get")) {
      int sysNameStartPosition = requestTarget.indexOf("/datamanager"+CommonConstants.OP_DATAMANAGER_HISTORIAN+"/");
      int sysNameStopPosition = -1;
      if ( sysNameStartPosition != -1) {
        sysNameStopPosition = requestTarget.indexOf("/", sysNameStartPosition + 0 + ("/datamanager"+CommonConstants.OP_DATAMANAGER_HISTORIAN+"/").length());
        String requestTargetSystemName = requestTarget.substring(sysNameStartPosition + ("/datamanager"+CommonConstants.OP_DATAMANAGER_HISTORIAN+"/").length(), sysNameStopPosition);

        //logger.info("reqtarget:" + requestTarget);
        //logger.info("start: "+sysNameStartPosition+", stop: " + sysNameStopPosition);
        //logger.info("rewqSysname: " + requestTargetSystemName);

        checkIfRequesterSystemNameisEqualsWithClientNameFromCN(requestTargetSystemName, clientCN);
        return;
      }

      if ( sysNameStartPosition == -1) {
        sysNameStartPosition = requestTarget.indexOf("/datamanager"+CommonConstants.OP_DATAMANAGER_PROXY+"/");
        sysNameStopPosition = requestTarget.indexOf("/", sysNameStartPosition + 0 + ("/datamanager"+CommonConstants.OP_DATAMANAGER_PROXY+"/").length());
        String requestTargetSystemName = requestTarget.substring(sysNameStartPosition + ("/datamanager"+CommonConstants.OP_DATAMANAGER_PROXY+"/").length(), sysNameStopPosition);

        //logger.info("rewqSysname: " + requestTargetSystemName);
        checkIfRequesterSystemNameisEqualsWithClientNameFromCN(requestTargetSystemName, clientCN);
        return;
      } else {
        throw new AuthException("Illegal request");
      }
    }

    /*if ( requestTarget.contains( CommonConstants.OP_DATAMANAGER_HISTORIAN) ) {
      final SenML req = Utilities.fromJson(requestJSON, SenML.class);
		} else if ( requestTarget.contains( CommonConstants.OP_DATAMANAGER_PROXY) ) {
      final SenML req = Utilities.fromJson(requestJSON, SenML.class);
    }*/

	}

	//-------------------------------------------------------------------------------------------------
        private void checkIfRequesterSystemNameisEqualsWithClientNameFromCN(final String requesterSystemName, final String clientCN) {
                final String clientNameFromCN = getClientNameFromCN(clientCN);
                
                if (Utilities.isEmpty(requesterSystemName) || Utilities.isEmpty(clientNameFromCN)) {
                        log.debug("Requester system name and client name from certificate do not match!");
                        throw new AuthException("Requester system name or client name from certificate is null or blank!", HttpStatus.UNAUTHORIZED.value());
                }
                
                if (!requesterSystemName.equalsIgnoreCase(clientNameFromCN) && !requesterSystemName.replaceAll("_", "").equalsIgnoreCase(clientNameFromCN)) {
                        log.debug("Requester system name and client name from certificate do not match!");
                        throw new AuthException("Requester system name(" + requesterSystemName + ") and client name from certificate (" + clientNameFromCN + ") do not match!", HttpStatus.UNAUTHORIZED.value());
                }
        }
        
        //-------------------------------------------------------------------------------------------------
        private String getClientNameFromCN(final String clientCN) {
                return clientCN.split("\\.", 2)[0];
        }
}