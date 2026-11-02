using GimXSoft.Api.Data;
using GimXSoft.Api.DTOs;
using GimXSoft.Api.Entities;
using GimXSoft.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace GimXSoft.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class MeasurementsController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ICurrentTenantService _tenantService;

    public MeasurementsController(ApplicationDbContext context, ICurrentTenantService tenantService)
    {
        _context = context;
        _tenantService = tenantService;
    }

    [HttpGet("member/{memberId:guid}")]
    public async Task<ActionResult<List<MemberMeasurementDto>>> GetMemberMeasurements(Guid memberId)
    {
        var measurements = await _context.MemberMeasurements
            .Include(m => m.Member)
            .Include(m => m.RecordedByUser)
            .Where(m => m.MemberId == memberId)
            .OrderByDescending(m => m.MeasurementDate)
            .Select(m => new MemberMeasurementDto(
                m.Id,
                m.MemberId,
                m.Member != null ? m.Member.FullName : "Member",
                m.WeightKg,
                m.HeightCm,
                m.CalculatedBmi,
                m.WaistCm,
                m.ChestCm,
                m.HipCm,
                m.LeftArmCm,
                m.RightArmCm,
                m.LeftThighCm,
                m.RightThighCm,
                m.BodyFatPercentage,
                m.InputUnitSystem.ToString(),
                m.MeasurementDate,
                m.RecordedByUserId,
                m.RecordedByUser != null ? m.RecordedByUser.FullName : null,
                m.Notes,
                m.WeightDifferenceKg,
                m.WeightChangePercent,
                m.CreatedAt
            ))
            .ToListAsync();

        return Ok(measurements);
    }

    [HttpPost]
    public async Task<ActionResult<MemberMeasurementDto>> RecordMeasurement([FromBody] RecordMeasurementRequest request)
    {
        var tenantId = _tenantService.TenantId ?? throw new UnauthorizedAccessException();
        var member = await _context.Members.FindAsync(request.MemberId);
        if (member == null) return NotFound(new { message = "Member not found." });

        // Standard Adult BMI Formula: Weight(kg) / (Height(m) ^ 2)
        var heightInMeters = request.HeightCm / 100m;
        var calculatedBmi = heightInMeters > 0
            ? Math.Round(request.WeightKg / (heightInMeters * heightInMeters), 2)
            : 0.00m;

        // Fetch baseline to compute total delta
        var baseline = await _context.MemberFitnessBaselines
            .FirstOrDefaultAsync(b => b.MemberId == request.MemberId);

        decimal? weightDiff = null;
        decimal? weightChangePct = null;

        if (baseline != null && baseline.InitialWeightKg > 0)
        {
            weightDiff = Math.Round(request.WeightKg - baseline.InitialWeightKg, 2);
            weightChangePct = Math.Round(((request.WeightKg - baseline.InitialWeightKg) / baseline.InitialWeightKg) * 100m, 2);
        }

        Enum.TryParse<UnitSystem>(request.UnitSystem, true, out var unitSystem);

        var measurement = new MemberMeasurement
        {
            TenantId = tenantId,
            MemberId = request.MemberId,
            WeightKg = request.WeightKg,
            HeightCm = request.HeightCm,
            CalculatedBmi = calculatedBmi,
            WaistCm = request.WaistCm,
            ChestCm = request.ChestCm,
            HipCm = request.HipCm,
            LeftArmCm = request.LeftArmCm,
            RightArmCm = request.RightArmCm,
            LeftThighCm = request.LeftThighCm,
            RightThighCm = request.RightThighCm,
            BodyFatPercentage = request.BodyFatPercentage,
            InputUnitSystem = unitSystem,
            MeasurementDate = request.MeasurementDate ?? DateTime.UtcNow.Date,
            RecordedByUserId = _tenantService.UserId,
            Notes = request.Notes,
            WeightDifferenceKg = weightDiff,
            WeightChangePercent = weightChangePct,
            CreatedAt = DateTime.UtcNow
        };

        _context.MemberMeasurements.Add(measurement);

        // Update onboarding journey if this is the first measurement
        var journey = await _context.MemberOnboardingJourneys
            .FirstOrDefaultAsync(j => j.MemberId == request.MemberId);
        if (journey != null && !journey.InitialMeasurementDone)
        {
            journey.InitialMeasurementDone = true;
            journey.InitialMeasurementDoneAt = DateTime.UtcNow;
            journey.UpdatedAt = DateTime.UtcNow;
        }

        await _context.SaveChangesAsync();

        return Ok(new MemberMeasurementDto(
            measurement.Id,
            measurement.MemberId,
            member.FullName,
            measurement.WeightKg,
            measurement.HeightCm,
            measurement.CalculatedBmi,
            measurement.WaistCm,
            measurement.ChestCm,
            measurement.HipCm,
            measurement.LeftArmCm,
            measurement.RightArmCm,
            measurement.LeftThighCm,
            measurement.RightThighCm,
            measurement.BodyFatPercentage,
            measurement.InputUnitSystem.ToString(),
            measurement.MeasurementDate,
            measurement.RecordedByUserId,
            null,
            measurement.Notes,
            measurement.WeightDifferenceKg,
            measurement.WeightChangePercent,
            measurement.CreatedAt
        ));
    }

    [HttpGet("progress-card/{memberId:guid}")]
    public async Task<ActionResult<FitnessProgressCardDto>> GetProgressCard(Guid memberId)
    {
        var member = await _context.Members.FindAsync(memberId);
        if (member == null) return NotFound(new { message = "Member not found." });

        var baseline = await _context.MemberFitnessBaselines
            .FirstOrDefaultAsync(b => b.MemberId == memberId);

        var measurements = await _context.MemberMeasurements
            .Where(m => m.MemberId == memberId)
            .OrderBy(m => m.MeasurementDate)
            .ToListAsync();

        var startingWeight = baseline?.InitialWeightKg ?? (measurements.FirstOrDefault()?.WeightKg ?? 75.0m);
        var latestMeasurement = measurements.LastOrDefault();
        var currentWeight = latestMeasurement?.WeightKg ?? startingWeight;
        var currentBmi = latestMeasurement?.CalculatedBmi ?? (baseline?.InitialBmi ?? 23.5m);

        var weightDiff = Math.Round(currentWeight - startingWeight, 2);
        var changePct = startingWeight > 0 ? Math.Round((weightDiff / startingWeight) * 100m, 2) : 0.0m;

        // BMI Screening Category
        var bmiCategory = currentBmi switch
        {
            < 18.5m => "Underweight",
            < 25.0m => "Normal Weight",
            < 30.0m => "Overweight",
            _ => "Obese"
        };

        var weightPoints = measurements.Select(m => new WeightDataPoint(m.MeasurementDate, m.WeightKg, m.CalculatedBmi)).ToList();
        var measurementPoints = measurements.Select(m => new MeasurementHistoryPoint(m.MeasurementDate, m.WaistCm, m.ChestCm, m.HipCm, m.BodyFatPercentage)).ToList();

        // Check if review is overdue (> 30 days since last measurement)
        var hasOverdueReview = latestMeasurement != null && (DateTime.UtcNow.Date - latestMeasurement.MeasurementDate).TotalDays > 30;

        return Ok(new FitnessProgressCardDto(
            member.Id,
            member.FullName,
            member.MemberCode,
            member.AvatarUrl,
            baseline?.FitnessGoal ?? "General Wellness",
            baseline?.FitnessLevel.ToString() ?? "Beginner",
            startingWeight,
            currentWeight,
            weightDiff,
            changePct,
            currentBmi,
            bmiCategory,
            latestMeasurement?.MeasurementDate,
            weightPoints,
            measurementPoints,
            hasOverdueReview
        ));
    }

    [HttpGet("baseline/{memberId:guid}")]
    public async Task<ActionResult<MemberFitnessBaselineDto>> GetBaseline(Guid memberId)
    {
        var baseline = await _context.MemberFitnessBaselines
            .Include(b => b.Member)
            .FirstOrDefaultAsync(b => b.MemberId == memberId);

        if (baseline == null)
        {
            var member = await _context.Members.FindAsync(memberId);
            if (member == null) return NotFound();

            return Ok(new MemberFitnessBaselineDto(
                Guid.Empty,
                member.Id,
                member.FullName,
                InitialWeightKg: 75.00m,
                HeightCm: 175.00m,
                InitialBmi: 24.49m,
                InitialMeasurementDate: member.JoiningDate,
                FitnessGoal: "Muscle Building & Fat Loss",
                FitnessLevel: "Beginner",
                TrainingFrequencyDaysPerWeek: 4,
                MedicalAndDietNotes: member.MedicalNotes
            ));
        }

        return Ok(new MemberFitnessBaselineDto(
            baseline.Id,
            baseline.MemberId,
            baseline.Member?.FullName ?? "Member",
            baseline.InitialWeightKg,
            baseline.HeightCm,
            baseline.InitialBmi,
            baseline.InitialMeasurementDate,
            baseline.FitnessGoal,
            baseline.FitnessLevel.ToString(),
            baseline.TrainingFrequencyDaysPerWeek,
            baseline.MedicalAndDietNotes
        ));
    }

    [HttpPost("baseline")]
    public async Task<ActionResult<MemberFitnessBaselineDto>> SaveBaseline([FromBody] CreateOrUpdateBaselineRequest request)
    {
        var tenantId = _tenantService.TenantId ?? throw new UnauthorizedAccessException();
        var member = await _context.Members.FindAsync(request.MemberId);
        if (member == null) return NotFound(new { message = "Member not found." });

        var heightMeters = request.HeightCm / 100m;
        var bmi = heightMeters > 0 ? Math.Round(request.InitialWeightKg / (heightMeters * heightMeters), 2) : 22.0m;

        Enum.TryParse<FitnessLevel>(request.FitnessLevel, true, out var level);

        var baseline = await _context.MemberFitnessBaselines
            .FirstOrDefaultAsync(b => b.MemberId == request.MemberId);

        if (baseline == null)
        {
            baseline = new MemberFitnessBaseline
            {
                TenantId = tenantId,
                MemberId = request.MemberId,
                InitialWeightKg = request.InitialWeightKg,
                HeightCm = request.HeightCm,
                InitialBmi = bmi,
                InitialMeasurementDate = DateTime.UtcNow.Date,
                FitnessGoal = request.FitnessGoal,
                FitnessLevel = level,
                TrainingFrequencyDaysPerWeek = request.TrainingFrequencyDaysPerWeek,
                MedicalAndDietNotes = request.MedicalAndDietNotes,
                CreatedAt = DateTime.UtcNow
            };
            _context.MemberFitnessBaselines.Add(baseline);
        }
        else
        {
            baseline.InitialWeightKg = request.InitialWeightKg;
            baseline.HeightCm = request.HeightCm;
            baseline.InitialBmi = bmi;
            baseline.FitnessGoal = request.FitnessGoal;
            baseline.FitnessLevel = level;
            baseline.TrainingFrequencyDaysPerWeek = request.TrainingFrequencyDaysPerWeek;
            baseline.MedicalAndDietNotes = request.MedicalAndDietNotes;
        }

        await _context.SaveChangesAsync();

        return Ok(new MemberFitnessBaselineDto(
            baseline.Id,
            baseline.MemberId,
            member.FullName,
            baseline.InitialWeightKg,
            baseline.HeightCm,
            baseline.InitialBmi,
            baseline.InitialMeasurementDate,
            baseline.FitnessGoal,
            baseline.FitnessLevel.ToString(),
            baseline.TrainingFrequencyDaysPerWeek,
            baseline.MedicalAndDietNotes
        ));
    }

    // --- Onboarding Journey ---
    [HttpGet("onboarding/{memberId:guid}")]
    public async Task<ActionResult<MemberOnboardingJourneyDto>> GetOnboarding(Guid memberId)
    {
        var journey = await _context.MemberOnboardingJourneys
            .Include(j => j.Member)
            .FirstOrDefaultAsync(j => j.MemberId == memberId);

        if (journey == null)
        {
            var member = await _context.Members.FindAsync(memberId);
            if (member == null) return NotFound();

            journey = new MemberOnboardingJourney
            {
                TenantId = member.TenantId,
                MemberId = member.Id,
                RegistrationCompleted = true,
                RegistrationCompletedAt = member.CreatedAt,
                ConsentCollected = true,
                ConsentCollectedAt = member.CreatedAt,
                WelcomeSent = true,
                WelcomeSentAt = member.CreatedAt,
                AssessmentCompleted = false,
                InitialMeasurementDone = false,
                TrainerAssigned = member.AssignedTrainerId.HasValue,
                TrainerAssignedAt = member.AssignedTrainerId.HasValue ? member.CreatedAt : null,
                WorkoutPlanAssigned = false,
                FirstWorkoutDelivered = false,
                FirstWeekReviewDone = false,
                UpdatedAt = DateTime.UtcNow
            };
            _context.MemberOnboardingJourneys.Add(journey);
            await _context.SaveChangesAsync();
        }

        return Ok(new MemberOnboardingJourneyDto(
            journey.Id,
            journey.MemberId,
            journey.Member?.FullName ?? "Member",
            journey.RegistrationCompleted,
            journey.RegistrationCompletedAt,
            journey.ConsentCollected,
            journey.ConsentCollectedAt,
            journey.WelcomeSent,
            journey.WelcomeSentAt,
            journey.AssessmentCompleted,
            journey.AssessmentCompletedAt,
            journey.InitialMeasurementDone,
            journey.InitialMeasurementDoneAt,
            journey.TrainerAssigned,
            journey.TrainerAssignedAt,
            journey.WorkoutPlanAssigned,
            journey.WorkoutPlanAssignedAt,
            journey.FirstWorkoutDelivered,
            journey.FirstWorkoutDeliveredAt,
            journey.FirstWeekReviewDone,
            journey.FirstWeekReviewDoneAt,
            journey.Notes,
            journey.UpdatedAt
        ));
    }

    [HttpPost("onboarding/stage")]
    public async Task<ActionResult> UpdateOnboardingStage([FromBody] UpdateOnboardingStageRequest request)
    {
        var journey = await _context.MemberOnboardingJourneys
            .FirstOrDefaultAsync(j => j.MemberId == request.MemberId);

        if (journey == null) return NotFound();

        var now = DateTime.UtcNow;
        switch (request.StageName)
        {
            case "AssessmentCompleted":
                journey.AssessmentCompleted = request.IsCompleted;
                journey.AssessmentCompletedAt = request.IsCompleted ? now : null;
                break;
            case "InitialMeasurementDone":
                journey.InitialMeasurementDone = request.IsCompleted;
                journey.InitialMeasurementDoneAt = request.IsCompleted ? now : null;
                break;
            case "TrainerAssigned":
                journey.TrainerAssigned = request.IsCompleted;
                journey.TrainerAssignedAt = request.IsCompleted ? now : null;
                break;
            case "WorkoutPlanAssigned":
                journey.WorkoutPlanAssigned = request.IsCompleted;
                journey.WorkoutPlanAssignedAt = request.IsCompleted ? now : null;
                break;
            case "FirstWorkoutDelivered":
                journey.FirstWorkoutDelivered = request.IsCompleted;
                journey.FirstWorkoutDeliveredAt = request.IsCompleted ? now : null;
                break;
            case "FirstWeekReviewDone":
                journey.FirstWeekReviewDone = request.IsCompleted;
                journey.FirstWeekReviewDoneAt = request.IsCompleted ? now : null;
                break;
        }

        if (!string.IsNullOrEmpty(request.Notes))
        {
            journey.Notes = request.Notes;
        }

        journey.UpdatedAt = now;
        await _context.SaveChangesAsync();

        return Ok(new { success = true, stage = request.StageName, isCompleted = request.IsCompleted });
    }
}
