package eu.arrowhead.core.onboarding;

import eu.arrowhead.common.CommonConstants;
import eu.arrowhead.common.database.service.CommonDBService;
import eu.arrowhead.core.onboarding.service.OnboardingService;
import org.mockito.Mockito;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.autoconfigure.jdbc.DataSourceTransactionManagerAutoConfiguration;
import org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.FilterType;
import org.springframework.context.annotation.Primary;

@Configuration
@ComponentScan(basePackages = CommonConstants.BASE_PACKAGE,
        excludeFilters = {
                @ComponentScan.Filter(type = FilterType.REGEX, pattern = ".*database.*"),
                @ComponentScan.Filter(type = FilterType.ASSIGNABLE_TYPE, classes = OnboardingMain.class),
        })
@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class, DataSourceTransactionManagerAutoConfiguration.class, HibernateJpaAutoConfiguration.class})
public class OnboardingTestContext {

    //=================================================================================================
    // methods

    //-------------------------------------------------------------------------------------------------
    @Bean
    @Primary // This bean is primary only in test context
    public OnboardingService mockOnboardingDBService() {
        return Mockito.mock(OnboardingService.class);
    }
}