package com.prepwise;

import org.flywaydb.core.Flyway;
import org.flywaydb.core.api.MigrationInfo;
import org.flywaydb.core.api.MigrationInfoService;
import org.flywaydb.core.api.MigrationState;
import org.flywaydb.core.api.MigrationVersion;
import org.junit.jupiter.api.Test;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.postgresql.PostgreSQLContainer;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.RestClient;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Integration tests for {@link PrepwiseApplication} against a real PostgreSQL.
 */
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
@Testcontainers
class PrepwiseApplicationTests {

	@Container
	@ServiceConnection
	static final PostgreSQLContainer postgres = new PostgreSQLContainer("postgres:17-alpine");

	@Value("${local.server.port}")
	private int port;

	@Autowired
	private Flyway flyway;

	@Test
	void healthEndpointReportsUp() {
		RestClient client = RestClient.create("http://localhost:" + this.port);
		ResponseEntity<String> response = client.get().uri("/actuator/health").retrieve().toEntity(String.class);
		assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
		assertThat(response.getBody()).contains("\"status\":\"UP\"");
	}

	@Test
	void flywayAppliesAllMigrationsIncludingBaseline() {
		MigrationInfoService info = this.flyway.info();
		assertThat(info.pending()).isEmpty();
		assertThat(info.applied()).extracting(MigrationInfo::getVersion).contains(MigrationVersion.fromVersion("1"));
		assertThat(info.applied()).extracting(MigrationInfo::getState).containsOnly(MigrationState.SUCCESS);
	}

}
