<?php

namespace Tests\Feature;

// use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ExampleTest extends TestCase
{
    /**
     * A basic test example.
     */
    public function test_the_application_returns_a_successful_response(): void
    {
        $response = $this->get('/');

        $response->assertRedirect('/inicio');
    }

    public function test_login_is_spanish_and_does_not_require_dni(): void
    {
        $this->get('/login')->assertOk()->assertSee('Usuario')->assertSee('Contraseña')->assertDontSee('name="dni"', false);
    }

    public function test_guest_cannot_access_employee_pages(): void
    {
        foreach (['/inicio', '/personal', '/horarios', '/calendario', '/solicitudes', '/reportes'] as $path) {
            $this->get($path)->assertRedirect('/login');
        }
    }

    public function test_security_headers_and_private_cache(): void
    {
        $this->get('/login')->assertHeader('X-Content-Type-Options', 'nosniff')->assertHeader('X-Frame-Options', 'DENY');
    }
}
