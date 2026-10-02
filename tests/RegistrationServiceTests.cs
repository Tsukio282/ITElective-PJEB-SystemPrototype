using CampusEventManagement;
using Moq;
using Xunit;

namespace CampusEventManagement.Tests
{
    public class RegistrationServiceTests
    {
        private readonly Mock<IRegistrationRepository> _repositoryMock;
        private readonly RegistrationService _service;

        public RegistrationServiceTests()
        {
            _repositoryMock = new Mock<IRegistrationRepository>();
            _service = new RegistrationService(_repositoryMock.Object);
        }

        [Fact]
        public void IsValidUniversityEmail_ValidUniversityEmail_ReturnsTrue()
        {
            const string email = "student@univ.edu.ph";

            bool result = _service.IsValidUniversityEmail(email);

            Assert.True(result);

            _repositoryMock.Verify(
                r => r.GetUserRegistration(It.IsAny<string>()),
                Times.Never);
        }

        [Fact]
        public void IsValidUniversityEmail_NonUniversityEmail_ReturnsFalse()
        {
            const string email = "student@gmail.com";

            bool result = _service.IsValidUniversityEmail(email);

            Assert.False(result);

            _repositoryMock.Verify(
                r => r.GetUserRegistration(It.IsAny<string>()),
                Times.Never);
        }

        [Theory]
        [InlineData(null)]
        [InlineData("")]
        [InlineData("   ")]
        public void IsValidUniversityEmail_NullOrEmptyEmail_ReturnsFalse(
            string? email)
        {
            bool result = _service.IsValidUniversityEmail(email);

            Assert.False(result);

            _repositoryMock.Verify(
                r => r.GetUserRegistration(It.IsAny<string>()),
                Times.Never);
        }

        [Theory]
        [InlineData("student")]
        [InlineData("student@")]
        [InlineData("@univ.edu.ph")]
        [InlineData("student@univ")]
        public void IsValidUniversityEmail_InvalidFormat_ReturnsFalse(
            string email)
        {
            bool result = _service.IsValidUniversityEmail(email);

            Assert.False(result);

            _repositoryMock.Verify(
                r => r.GetUserRegistration(It.IsAny<string>()),
                Times.Never);
        }

        [Fact]
        public void GetUserRegistration_ValidUniversityEmail_CallsRepositoryOnce()
        {
            const string email = "student@univ.edu.ph";
            const string expectedRegistration = "Event Registration #1001";

            _repositoryMock
                .Setup(r => r.GetUserRegistration(email))
                .Returns(expectedRegistration);

            string? result = _service.GetUserRegistration(email);

            Assert.Equal(expectedRegistration, result);

            _repositoryMock.Verify(
                r => r.GetUserRegistration(email),
                Times.Once);
        }

        [Theory]
        [InlineData("student@gmail.com")]
        [InlineData("invalid")]
        [InlineData("")]
        [InlineData(null)]
        public void GetUserRegistration_InvalidEmail_DoesNotCallRepository(
            string? email)
        {
            string? result = _service.GetUserRegistration(email);

            Assert.Null(result);

            _repositoryMock.Verify(
                r => r.GetUserRegistration(It.IsAny<string>()),
                Times.Never);
        }
    }
}