package eu.arrowhead.core.authorization.token;

import static org.mockito.Mockito.when;

import java.security.KeyStore;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.jose4j.jwa.AlgorithmConstraints;
import org.jose4j.jwa.AlgorithmConstraints.ConstraintType;
import org.jose4j.jwt.JwtClaims;
import org.jose4j.jwt.consumer.JwtConsumer;
import org.jose4j.jwt.consumer.JwtConsumerBuilder;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.util.ReflectionTestUtils;

import eu.arrowhead.common.CommonConstants;
import eu.arrowhead.common.Utilities;
import eu.arrowhead.common.database.service.CommonDBService;
import eu.arrowhead.common.dto.CloudRequestDTO;
import eu.arrowhead.common.dto.SystemRequestDTO;
import eu.arrowhead.common.dto.TokenGenerationRequestDTO;
import eu.arrowhead.common.exception.ArrowheadException;
import eu.arrowhead.common.exception.DataNotFoundException;
import eu.arrowhead.common.exception.InvalidParameterException;
import eu.arrowhead.core.authorization.AuthorizationMain;

@RunWith(SpringRunner.class)
@SpringBootTest(classes = AuthorizationMain.class)
public class TokenGenerationServiceTest {

	//=================================================================================================
	// members

	private static final String authInfo = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1aaeuv1I4bF5dxMIvUvLMxjRn309kdJewIIH08DfL17/LSssD70ZaLz0yxNfbPPQpFK8LMK+HQHDiGZH5yp4qJDuEgfmUrqWibnBIBc/K3Ob45lQy0zdFVtFsVJYBFVymQwgxJT6th0hI3RGLbCJMzbmpDzT7g0IDsN+64tMyi08ZCPrqk99uzYgioSSWNb9bhG2Z9646b3oiY5utQWRhP/2z/t6vVJHtRYeyaXPl6Z2M/5KnjpSvpSeZQhNrw+Is1DEE5DHiEjfQFWrLwDOqPKDrvmFyIlJ7P7OCMax6dIlSB7GEQSSP+j4eIxDWgjm+Pv/c02UVDc0x3xX/UGtNwIDAQAB";

	@InjectMocks
	private TokenGenerationService tokenGenerationService;
	
	@Mock
	private CommonDBService commonDBService;
	
	@Mock
	private Map<String,Object> arrowheadContext;
	
	@Resource(name = CommonConstants.ARROWHEAD_CONTEXT)
	private Map<String,Object> validArrowheadContext;

	//=================================================================================================
	// methods
	
	//-------------------------------------------------------------------------------------------------
	@Before
	public void init() {
		ReflectionTestUtils.setField(tokenGenerationService, "sslEnabled", true);
	}
	
	//-------------------------------------------------------------------------------------------------
	@Test(expected = ArrowheadException.class)
	public void testGenerateTokenInsecureMode() {
		ReflectionTestUtils.setField(tokenGenerationService, "sslEnabled", false);
		tokenGenerationService.generateTokens(null);
	}
	
	//-------------------------------------------------------------------------------------------------
	@Test(expected = IllegalArgumentException.class)
	public void testGenerateTokenNullRequest() {
		tokenGenerationService.generateTokens(null);
	}
	
	//-------------------------------------------------------------------------------------------------
	@Test(expected = InvalidParameterException.class)
	public void testGenerateTokenNullConsumer() {
		tokenGenerationService.generateTokens(new TokenGenerationRequestDTO());
	}
	
	//-------------------------------------------------------------------------------------------------
	@Test(expected = InvalidParameterException.class)
	public void testGenerateTokenConsumerNameNull() {
		final SystemRequestDTO consumer = new SystemRequestDTO();
		final TokenGenerationRequestDTO request = new TokenGenerationRequestDTO(consumer, null, List.of(new SystemRequestDTO()), "testService", null);
		tokenGenerationService.generateTokens(request);
	}
	
	//-------------------------------------------------------------------------------------------------
	@Test(expected = InvalidParameterException.class)
	public void testGenerateTokenConsumerNameEmpty() {
		final SystemRequestDTO consumer = new SystemRequestDTO();
		consumer.setSystemName(" ");
		final TokenGenerationRequestDTO request = new TokenGenerationRequestDTO(consumer, null, List.of(new SystemRequestDTO()), "testService", null);
		tokenGenerationService.generateTokens(request);
	}
	
	//-------------------------------------------------------------------------------------------------
	@Test(expected = InvalidParameterException.class)
	public void testGenerateTokenConsumerCloudOperatorNull() {
		final SystemRequestDTO consumer = new SystemRequestDTO();
		consumer.setSystemName("consumer");
		final TokenGenerationRequestDTO request = new TokenGenerationRequestDTO(consumer, new CloudRequestDTO(), List.of(new SystemRequestDTO()), "testService", null);
		tokenGenerationService.generateTokens(request);
	}
	
	//-------------------------------------------------------------------------------------------------
	@Test(expected = InvalidParameterException.class)
	public void testGenerateTokenConsumerCloudOperatorEmpty() {
		final SystemRequestDTO consumer = new SystemRequestDTO();
		consumer.setSystemName("consumer");
		final CloudRequestDTO consumerCloud = new CloudRequestDTO();
		consumerCloud.setOperator(" ");
		final TokenGenerationRequestDTO request = new TokenGenerationRequestDTO(consumer, consumerCloud, List.of(new SystemRequestDTO()), "testService", null);
		tokenGenerationService.generateTokens(request);
	}
	
	//-------------------------------------------------------------------------------------------------
	@Test(expected = InvalidParameterException.class)
	public void testGenerateTokenConsumerCloudNameNull() {
		final SystemRequestDTO consumer = new SystemRequestDTO();
		consumer.setSystemName("consumer");
		final CloudRequestDTO consumerCloud = new CloudRequestDTO();
		consumerCloud.setOperator("aitia");
		final TokenGenerationRequestDTO request = new TokenGenerationRequestDTO(consumer, consumerCloud, List.of(new SystemRequestDTO()), "testService", null);
		tokenGenerationService.generateTokens(request);
	}
	
	//-------------------------------------------------------------------------------------------------
	@Test(expected = InvalidParameterException.class)
	public void testGenerateTokenConsumerCloudNameEmpty() {
		final SystemRequestDTO consumer = new SystemRequestDTO();
		consumer.setSystemName("consumer");
		final CloudRequestDTO consumerCloud = new CloudRequestDTO();
		consumerCloud.setOperator("aitia");
		consumerCloud.setName(" ");
		final TokenGenerationRequestDTO request = new TokenGenerationRequestDTO(consumer, consumerCloud, List.of(new SystemRequestDTO()), "testService", null);
		tokenGenerationService.generateTokens(request);
	}
	
	//-------------------------------------------------------------------------------------------------
	@Test(expected = InvalidParameterException.class)
	public void testGenerateTokenProvidersListNull() {
		final SystemRequestDTO consumer = new SystemRequestDTO();
		consumer.setSystemName("consumer");
		final TokenGenerationRequestDTO request = new TokenGenerationRequestDTO(consumer, null, List.of(new SystemRequestDTO()), "testService", null);
		request.setProviders(null);
		tokenGenerationService.generateTokens(request);
	}
	
	//-------------------------------------------------------------------------------------------------
	@Test(expected = InvalidParameterException.class)
	public void testGenerateTokenProvidersListEmpty() {
		final SystemRequestDTO consumer = new SystemRequestDTO();
		consumer.setSystemName("consumer");
		final TokenGenerationRequestDTO request = new TokenGenerationRequestDTO(consumer, null, List.of(new SystemRequestDTO()), "testService", null);
		request.setProviders(List.of());
		tokenGenerationService.generateTokens(request);
	}
	
	//-------------------------------------------------------------------------------------------------
	@Test(expected = InvalidParameterException.class)
	public void testGenerateTokenProviderNameNull() {
		final SystemRequestDTO consumer = new SystemRequestDTO();
		consumer.setSystemName("consumer");
		final TokenGenerationRequestDTO request = new TokenGenerationRequestDTO(consumer, null, List.of(new SystemRequestDTO()), "testService", null);
		tokenGenerationService.generateTokens(request);
	}
	
	//-------------------------------------------------------------------------------------------------
	@Test(expected = InvalidParameterException.class)
	public void testGenerateTokenProviderNameEmpty() {
		final SystemRequestDTO consumer = new SystemRequestDTO();
		consumer.setSystemName("consumer");
		final SystemRequestDTO provider = new SystemRequestDTO();
		provider.setSystemName(" ");
		final TokenGenerationRequestDTO request = new TokenGenerationRequestDTO(consumer, null, List.of(provider), "testService", null);
		tokenGenerationService.generateTokens(request);
	}
	
	//-------------------------------------------------------------------------------------------------
	@Test(expected = InvalidParameterException.class)
	public void testGenerateTokenServiceNull() {
		final SystemRequestDTO consumer = new SystemRequestDTO();
		consumer.setSystemName("consumer");
		final SystemRequestDTO provider = new SystemRequestDTO();
		provider.setSystemName(" ");
		final TokenGenerationRequestDTO request = new TokenGenerationRequestDTO(consumer, null, List.of(provider), "testService", null);
		request.setService(null);
		tokenGenerationService.generateTokens(request);
	}
	
	//-------------------------------------------------------------------------------------------------
	@Test(expected = InvalidParameterException.class)
	public void testGenerateTokenServiceEmpty() {
		final SystemRequestDTO consumer = new SystemRequestDTO();
		consumer.setSystemName("consumer");
		final SystemRequestDTO provider = new SystemRequestDTO();
		provider.setSystemName(" ");
		final TokenGenerationRequestDTO request = new TokenGenerationRequestDTO(consumer, null, List.of(provider), "testService", null);
		request.setService("  \t");
		tokenGenerationService.generateTokens(request);
	}
	
	//-------------------------------------------------------------------------------------------------
	@Test(expected = InvalidParameterException.class)
	public void testGenerateTokenProviderHasNoKey() {
		final SystemRequestDTO consumer = new SystemRequestDTO();
		consumer.setSystemName("consumer");
		final SystemRequestDTO provider = new SystemRequestDTO();
		provider.setSystemName("provider");
		final TokenGenerationRequestDTO request = new TokenGenerationRequestDTO(consumer, null, List.of(provider), "testService", null);
		tokenGenerationService.generateTokens(request);
	}
	
	//-------------------------------------------------------------------------------------------------
	@Test(expected = InvalidParameterException.class)
	public void testGenerateTokenProviderHasNotValidKey() {
		final SystemRequestDTO consumer = new SystemRequestDTO();
		consumer.setSystemName("consumer");
		final SystemRequestDTO provider = new SystemRequestDTO();
		provider.setSystemName("provider");
		provider.setAuthenticationInfo("bm90IGEga2V5");
		final TokenGenerationRequestDTO request = new TokenGenerationRequestDTO(consumer, null, List.of(provider), "testService", null);
		tokenGenerationService.generateTokens(request);
	}
	
	//-------------------------------------------------------------------------------------------------
	@Test(expected = ArrowheadException.class)
	public void testGenerateTokenProviderInitOwnCloudFromCertificateNoCommonName() {
		when(commonDBService.getOwnCloud(true)).thenThrow(new DataNotFoundException("own cloud not found"));
		
		final SystemRequestDTO consumer = new SystemRequestDTO();
		consumer.setSystemName("consumer");
		final SystemRequestDTO provider = new SystemRequestDTO();
		provider.setSystemName("provider");
		provider.setAuthenticationInfo(authInfo);
		final TokenGenerationRequestDTO request = new TokenGenerationRequestDTO(consumer, null, List.of(provider), "testService", null);
		tokenGenerationService.generateTokens(request);
	}
	
	//-------------------------------------------------------------------------------------------------
	@Test(expected = ArrowheadException.class)
	public void testGenerateTokenProviderNoServerPrivateKey() {
		final SystemRequestDTO consumer = new SystemRequestDTO();
		consumer.setSystemName("consumer");
		final CloudRequestDTO cloud = new CloudRequestDTO();
		cloud.setOperator("aitia");
		cloud.setName("testcloud2");
		final SystemRequestDTO provider = new SystemRequestDTO();
		provider.setSystemName("provider");
		provider.setAuthenticationInfo(authInfo);
		final TokenGenerationRequestDTO request = new TokenGenerationRequestDTO(consumer, cloud, List.of(provider), "testService", null);
		tokenGenerationService.generateTokens(request);
	}
	
	//-------------------------------------------------------------------------------------------------
	@Test(expected = ArrowheadException.class)
	public void testGenerateTokenProviderErrorWhileSigning() throws Exception {
		when(arrowheadContext.containsKey(CommonConstants.SERVER_PRIVATE_KEY)).thenReturn(true);
		when(arrowheadContext.get(CommonConstants.SERVER_PRIVATE_KEY)).thenReturn(getInvalidKey());
		final SystemRequestDTO consumer = new SystemRequestDTO();
		consumer.setSystemName("consumer");
		final CloudRequestDTO cloud = new CloudRequestDTO();
		cloud.setOperator("aitia");
		cloud.setName("testcloud2");
		final SystemRequestDTO provider = new SystemRequestDTO();
		provider.setSystemName("provider");
		provider.setAuthenticationInfo(authInfo);
		final TokenGenerationRequestDTO request = new TokenGenerationRequestDTO(consumer, cloud, List.of(provider), "testService", null);
		tokenGenerationService.generateTokens(request);
	}
	
	//-------------------------------------------------------------------------------------------------
	@Test
	public void testTokenGenerationOk() throws Exception {
		when(arrowheadContext.containsKey(CommonConstants.SERVER_PRIVATE_KEY)).thenReturn(true);
		when(arrowheadContext.get(CommonConstants.SERVER_PRIVATE_KEY)).thenReturn(validArrowheadContext.get(CommonConstants.SERVER_PRIVATE_KEY));
		
		final SystemRequestDTO consumer = new SystemRequestDTO();
		consumer.setSystemName("consumer");
		final CloudRequestDTO cloud = new CloudRequestDTO();
		cloud.setOperator("aitia");
		cloud.setName("testcloud2");
		final SystemRequestDTO provider = new SystemRequestDTO();
		provider.setSystemName("provider");
		provider.setAuthenticationInfo(authInfo);
		final TokenGenerationRequestDTO request = new TokenGenerationRequestDTO(consumer, cloud, List.of(provider), "testservice", 10);
		final Map<SystemRequestDTO,String> tokens = tokenGenerationService.generateTokens(request);
		Assert.assertTrue(!tokens.isEmpty());
		Assert.assertTrue(tokens.containsKey(provider));
		final String encryptedToken = tokens.get(provider);
		Assert.assertTrue(!Utilities.isEmpty(encryptedToken));
		
		final AlgorithmConstraints jwsAlgConstraints = new AlgorithmConstraints(ConstraintType.WHITELIST, CommonConstants.JWS_SIGN_ALG);
		final AlgorithmConstraints jweAlgConstraints = new AlgorithmConstraints(ConstraintType.WHITELIST, CommonConstants.JWE_KEY_MANAGEMENT_ALG);
		final AlgorithmConstraints jweEncConstraints = new AlgorithmConstraints(ConstraintType.WHITELIST, CommonConstants.JWE_ENCRYPTION_ALG);
		final PublicKey authPublicKey = (PublicKey) validArrowheadContext.get(CommonConstants.SERVER_PUBLIC_KEY);
		
		final KeyStore keystore = KeyStore.getInstance("PKCS12");
		keystore.load(Thread.currentThread().getContextClassLoader().getResourceAsStream("certificates/provider.p12"), "123456".toCharArray());
		final PrivateKey providerPrivateKey = Utilities.getPrivateKey(keystore, "123456");
		
		final JwtConsumer jwtConsumer = new JwtConsumerBuilder().setRequireJwtId()
																.setRequireNotBefore()
																.setEnableRequireEncryption()
																.setEnableRequireIntegrity()
																.setExpectedIssuer(CommonConstants.CORE_SYSTEM_AUTHORIZATION)
																.setDecryptionKey(providerPrivateKey)
																.setVerificationKey(authPublicKey)
																.setJwsAlgorithmConstraints(jwsAlgConstraints)
																.setJweAlgorithmConstraints(jweAlgConstraints)
																.setJweContentEncryptionAlgorithmConstraints(jweEncConstraints)
																.build();
		
		final JwtClaims claims = jwtConsumer.processToClaims(encryptedToken);
		Assert.assertTrue(claims.isClaimValueString(CommonConstants.JWT_CLAIM_CONSUMER_ID));
		Assert.assertEquals("consumer.testcloud2.aitia", claims.getStringClaimValue(CommonConstants.JWT_CLAIM_CONSUMER_ID));
		Assert.assertTrue(claims.isClaimValueString(CommonConstants.JWT_CLAIM_SERVICE_ID));
		Assert.assertEquals("testservice", claims.getStringClaimValue(CommonConstants.JWT_CLAIM_SERVICE_ID));
		Assert.assertTrue(System.currentTimeMillis() < claims.getExpirationTime().getValueInMillis());
	}
	
	//=================================================================================================
	// assistant method
	
	//-------------------------------------------------------------------------------------------------
	@SuppressWarnings("serial")
	private PrivateKey getInvalidKey() {
		return new PrivateKey() {
			public String getFormat() { return null; }
			public byte[] getEncoded() { return null; }
			public String getAlgorithm() { return null;	}
		};
	}
}