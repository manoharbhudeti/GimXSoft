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
public class ExercisesController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ICurrentTenantService _tenantService;

    public ExercisesController(ApplicationDbContext context, ICurrentTenantService tenantService)
    {
        _context = context;
        _tenantService = tenantService;
    }

    [HttpGet]
    public async Task<ActionResult<List<ExerciseDto>>> GetExercises(
        [FromQuery] string? search,
        [FromQuery] string? category,
        [FromQuery] string? muscle,
        [FromQuery] string? difficulty)
    {
        var query = _context.Exercises.Where(e => e.IsActive);

        if (!string.IsNullOrWhiteSpace(search))
        {
            var s = search.ToLower().Trim();
            query = query.Where(e => e.Name.ToLower().Contains(s) || e.Description.ToLower().Contains(s));
        }

        if (!string.IsNullOrWhiteSpace(category) && category != "All")
        {
            query = query.Where(e => e.Category.ToLower() == category.ToLower());
        }

        if (!string.IsNullOrWhiteSpace(muscle) && muscle != "All")
        {
            query = query.Where(e => e.TargetMuscle.ToLower() == muscle.ToLower());
        }

        if (!string.IsNullOrWhiteSpace(difficulty) && Enum.TryParse<FitnessLevel>(difficulty, true, out var level))
        {
            query = query.Where(e => e.DifficultyLevel == level);
        }

        var exercises = await query
            .OrderBy(e => e.Name)
            .Select(e => new ExerciseDto(
                e.Id,
                e.TenantId,
                e.Name,
                e.Description,
                e.Category,
                e.TargetMuscle,
                e.SecondaryMusclesJson,
                e.Equipment,
                e.DifficultyLevel.ToString(),
                e.Instructions,
                e.DefaultSets,
                e.DefaultReps,
                e.DefaultRestSeconds,
                e.DurationSeconds,
                e.DemoImageUrl,
                e.DemoVideoUrl,
                e.SafetyNotes,
                e.IsActive,
                e.CreatedAt
            ))
            .ToListAsync();

        return Ok(exercises);
    }

    [HttpGet("categories")]
    public async Task<ActionResult<List<ExerciseCategoryDto>>> GetCategories()
    {
        var categories = await _context.ExerciseCategories
            .OrderBy(c => c.Name)
            .Select(c => new ExerciseCategoryDto(
                c.Id,
                c.Name,
                c.Description,
                c.IconName
            ))
            .ToListAsync();

        return Ok(categories);
    }

    [HttpPost]
    public async Task<ActionResult<ExerciseDto>> CreateExercise([FromBody] CreateExerciseRequest request)
    {
        var tenantId = _tenantService.TenantId ?? throw new UnauthorizedAccessException();

        Enum.TryParse<FitnessLevel>(request.DifficultyLevel, true, out var difficulty);

        var exercise = new Exercise
        {
            TenantId = tenantId,
            Name = request.Name.Trim(),
            Description = request.Description ?? "",
            Category = request.Category ?? "Strength",
            TargetMuscle = request.TargetMuscle ?? "Chest",
            SecondaryMusclesJson = request.SecondaryMusclesJson ?? "[]",
            Equipment = request.Equipment ?? "Barbell",
            DifficultyLevel = difficulty,
            Instructions = request.Instructions ?? "",
            DefaultSets = request.DefaultSets > 0 ? request.DefaultSets : 3,
            DefaultReps = request.DefaultReps ?? "10-12",
            DefaultRestSeconds = request.DefaultRestSeconds > 0 ? request.DefaultRestSeconds : 60,
            DurationSeconds = request.DurationSeconds,
            DemoImageUrl = request.DemoImageUrl,
            DemoVideoUrl = request.DemoVideoUrl,
            SafetyNotes = request.SafetyNotes,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        _context.Exercises.Add(exercise);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetExercises), new { id = exercise.Id }, new ExerciseDto(
            exercise.Id,
            exercise.TenantId,
            exercise.Name,
            exercise.Description,
            exercise.Category,
            exercise.TargetMuscle,
            exercise.SecondaryMusclesJson,
            exercise.Equipment,
            exercise.DifficultyLevel.ToString(),
            exercise.Instructions,
            exercise.DefaultSets,
            exercise.DefaultReps,
            exercise.DefaultRestSeconds,
            exercise.DurationSeconds,
            exercise.DemoImageUrl,
            exercise.DemoVideoUrl,
            exercise.SafetyNotes,
            exercise.IsActive,
            exercise.CreatedAt
        ));
    }

    [HttpDelete("{id:guid}")]
    public async Task<ActionResult> DeleteExercise(Guid id)
    {
        var ex = await _context.Exercises.FindAsync(id);
        if (ex == null) return NotFound();

        ex.IsActive = false;
        await _context.SaveChangesAsync();
        return Ok(new { success = true, id });
    }
}
