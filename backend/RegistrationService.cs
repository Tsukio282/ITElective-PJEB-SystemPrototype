using System;
using System.Data;
using System.Data.SqlClient;

namespace CampusEventManagement
{
    public interface IRegistrationRepository
    {
        string? GetUserRegistration(string email);
    }

    public class RegistrationService
    {
        private const string UniversityDomain = "@univ.edu.ph";

        private readonly IRegistrationRepository _repository;

        public RegistrationService(IRegistrationRepository repository)
        {
            _repository = repository
                ?? throw new ArgumentNullException(nameof(repository));
        }

        public bool IsValidUniversityEmail(string? email)
        {
            if (string.IsNullOrWhiteSpace(email))
            {
                return false;
            }

            if (!email.Contains("@"))
            {
                return false;
            }

            if (!email.EndsWith(
                    UniversityDomain,
                    StringComparison.OrdinalIgnoreCase))
            {
                return false;
            }

            string[] parts = email.Split('@');

            if (parts.Length != 2 ||
                string.IsNullOrWhiteSpace(parts[0]) ||
                string.IsNullOrWhiteSpace(parts[1]))
            {
                return false;
            }

            return true;
        }

        public string? GetUserRegistration(string? inputEmail)
        {
            if (!IsValidUniversityEmail(inputEmail))
            {
                return null;
            }

            return _repository.GetUserRegistration(inputEmail!);
        }
    }

    public class SqlRegistrationRepository : IRegistrationRepository
    {
        private readonly string _connectionString;

        public SqlRegistrationRepository(string connectionString)
        {
            if (string.IsNullOrWhiteSpace(connectionString))
            {
                throw new ArgumentException(
                    "A database connection string is required.",
                    nameof(connectionString));
            }

            _connectionString = connectionString;
        }

        public string? GetUserRegistration(string email)
        {
            const string sql = @"
                SELECT RegistrationId
                FROM Registrations
                WHERE Email = @email;";

            using (SqlConnection conn =
                   new SqlConnection(_connectionString))
            using (SqlCommand cmd =
                   new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add(
                    "@email",
                    SqlDbType.NVarChar,
                    255).Value = email;

                conn.Open();

                object? result = cmd.ExecuteScalar();

                if (result == null || result == DBNull.Value)
                {
                    return null;
                }

                return result.ToString();
            }
        }
    }
}