package com.prepwise;

import org.testcontainers.postgresql.PostgreSQLContainer;

import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.context.annotation.Bean;

/**
 * Real infrastructure for integration tests, shared through Spring's context cache.
 */
@TestConfiguration(proxyBeanMethods = false)
class TestcontainersConfiguration {

	// A bean (not a static @Container field) so Spring owns the lifecycle: a cached
	// context reused by another test class never points at a stopped database.
	@Bean
	@ServiceConnection
	PostgreSQLContainer postgresContainer() {
		return new PostgreSQLContainer("postgres:17-alpine");
	}

}
