using GimXSoft.Api.Entities;
using Microsoft.EntityFrameworkCore;

namespace GimXSoft.Api.Data;

public static class DbInitializer
{
    public static async Task SeedAsync(ApplicationDbContext context)
    {
        await context.Database.EnsureCreatedAsync();

        if (await context.Tenants.IgnoreQueryFilters().AnyAsync())
        {
            return; // Already seeded
        }

        // 1. Create Demo Tenant
        var tenant = new Tenant
        {
            Id = Guid.NewGuid(),
            Name = "Titan Fitness & Performance Club",
            Slug = "titan-fitness",
            LogoUrl = "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=128&q=80",
            SubscriptionPlan = "Enterprise Pro",
            SubscriptionStatus = "Active",
            MaxBranches = 10,
            MaxMembers = 5000,
            CreatedAt = DateTime.UtcNow.AddMonths(-12)
        };
        context.Tenants.Add(tenant);

        // 2. Create Branches
        var branchDowntown = new Branch
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            Name = "Downtown Flagship Club",
            Code = "DT-01",
            Address = "100 Central Avenue, Suite 400",
            City = "Metropolis",
            Phone = "+1 (555) 234-5678",
            Email = "downtown@titanfit.com",
            CreatedAt = DateTime.UtcNow.AddMonths(-12)
        };

        var branchWestside = new Branch
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            Name = "Westside Health & Wellness",
            Code = "WS-02",
            Address = "450 Sunset Boulevard",
            City = "Westland",
            Phone = "+1 (555) 987-6543",
            Email = "westside@titanfit.com",
            CreatedAt = DateTime.UtcNow.AddMonths(-8)
        };
        context.Branches.AddRange(branchDowntown, branchWestside);

        // 3. Create Users / Staff
        var passwordHash = BCrypt.Net.BCrypt.HashPassword("Admin123!");

        var owner = new User
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            BranchId = null, // All branches
            FullName = "Alexander Morgan",
            Email = "admin@titanfit.com",
            PasswordHash = passwordHash,
            Role = UserRole.GymOwner,
            Phone = "+1 (555) 100-0001",
            AvatarUrl = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&q=80",
            CreatedAt = DateTime.UtcNow.AddMonths(-12)
        };

        var manager = new User
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            BranchId = branchDowntown.Id,
            FullName = "Sarah Jenkins",
            Email = "sarah.manager@titanfit.com",
            PasswordHash = passwordHash,
            Role = UserRole.BranchManager,
            Phone = "+1 (555) 100-0002",
            AvatarUrl = "https://images.unsplash.com/photo-1580489944761-15a19d654956?w=120&q=80",
            CreatedAt = DateTime.UtcNow.AddMonths(-10)
        };

        var receptionist = new User
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            BranchId = branchDowntown.Id,
            FullName = "Marcus Reid",
            Email = "marcus.desk@titanfit.com",
            PasswordHash = passwordHash,
            Role = UserRole.Receptionist,
            Phone = "+1 (555) 100-0003",
            AvatarUrl = "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=120&q=80",
            CreatedAt = DateTime.UtcNow.AddMonths(-6)
        };

        var trainer1 = new User
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            BranchId = branchDowntown.Id,
            FullName = "David Kovacs",
            Email = "david.trainer@titanfit.com",
            PasswordHash = passwordHash,
            Role = UserRole.Trainer,
            Phone = "+1 (555) 100-0004",
            AvatarUrl = "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120&q=80",
            CreatedAt = DateTime.UtcNow.AddMonths(-8)
        };

        var trainer2 = new User
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            BranchId = branchWestside.Id,
            FullName = "Elena Rostova",
            Email = "elena.trainer@titanfit.com",
            PasswordHash = passwordHash,
            Role = UserRole.Trainer,
            Phone = "+1 (555) 100-0005",
            AvatarUrl = "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=120&q=80",
            CreatedAt = DateTime.UtcNow.AddMonths(-7)
        };

        context.Users.AddRange(owner, manager, receptionist, trainer1, trainer2);

        // 4. Create Trainer Profiles
        var trainerProfile1 = new TrainerProfile
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            UserId = trainer1.Id,
            Bio = "Former national powerlifting champion. Specializes in barbell mechanics, progressive overload, and athletic hypertrophy.",
            SpecializationsJson = "[\"Powerlifting\", \"Strength & Conditioning\", \"Hypertrophy\", \"Olympic Lifting\"]",
            CertificationsJson = "[\"CSCS Certified\", \"USAW Level 2\", \"Precision Nutrition L1\"]",
            HourlyRate = 65.00m
        };

        var trainerProfile2 = new TrainerProfile
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            UserId = trainer2.Id,
            Bio = "Functional mobility and endurance expert. Passionate about posture correction, metabolic conditioning, and calisthenics.",
            SpecializationsJson = "[\"Mobility & Flexibility\", \"HIIT Conditioning\", \"Pilates Core\", \"Rehabilitation\"]",
            CertificationsJson = "[\"ACE Certified Personal Trainer\", \"FMS Functional Movement Specialist\"]",
            HourlyRate = 60.00m
        };
        context.TrainerProfiles.AddRange(trainerProfile1, trainerProfile2);

        // 5. Create Membership Plans
        var planMonthly = new MembershipPlan
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            Name = "Monthly Pro Pass",
            Description = "Standard monthly membership with complete gym floor access and locker access.",
            DurationDays = 30,
            Price = 79.00m,
            RegistrationFee = 25.00m,
            BenefitsJson = "[\"Unlimited Gym Floor Access\", \"Cardio & Free Weight Zones\", \"Standard Locker Access\", \"Mobile App Access\"]",
            IsPersonalTraining = false,
            IncludedSessions = 0
        };

        var planQuarterly = new MembershipPlan
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            Name = "Quarterly Transformation",
            Description = "Our most popular 3-month commitment plan with complimentary body composition scans.",
            DurationDays = 90,
            Price = 219.00m,
            RegistrationFee = 0.00m,
            BenefitsJson = "[\"Full Access All Zones\", \"Free InBody Composition Scan\", \"1 Complimentary Trainer Session\", \"10% Smoothie Bar Discount\"]",
            IsPersonalTraining = false,
            IncludedSessions = 1
        };

        var planAnnual = new MembershipPlan
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            Name = "Annual Elite All-Access",
            Description = "Premium 365-day access across all branches, sauna, steam room, and guest passes.",
            DurationDays = 365,
            Price = 749.00m,
            RegistrationFee = 0.00m,
            BenefitsJson = "[\"Multi-Branch All-Access\", \"Sauna & Steam Lounge Access\", \"5 Guest Passes per year\", \"Priority Class Booking\", \"Free Titan Swag Kit\"]",
            IsPersonalTraining = false,
            IncludedSessions = 3
        };

        var planPT = new MembershipPlan
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            Name = "Personal Training 10-Pack",
            Description = "Dedicated one-on-one personal coaching pack with custom nutrition & workout plan.",
            DurationDays = 60,
            Price = 550.00m,
            RegistrationFee = 0.00m,
            BenefitsJson = "[\"10 One-on-One 60m Sessions\", \"Custom Workout Plan\", \"Weekly Macro Target Reviews\", \"Direct Trainer Messaging\"]",
            IsPersonalTraining = true,
            IncludedSessions = 10
        };
        context.MembershipPlans.AddRange(planMonthly, planQuarterly, planAnnual, planPT);

        // 6. Create Members
        var member1 = new Member
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            BranchId = branchDowntown.Id,
            MemberCode = "GIX-1001",
            FirstName = "James",
            LastName = "Wilson",
            Email = "james.wilson@example.com",
            Phone = "+1 (555) 301-8841",
            Gender = "Male",
            DateOfBirth = new DateTime(1992, 4, 15),
            Address = "742 Evergreen Terrace, Metropolis",
            EmergencyContactName = "Emily Wilson",
            EmergencyContactPhone = "+1 (555) 301-8842",
            JoiningDate = DateTime.UtcNow.AddMonths(-6),
            AssignedTrainerId = trainer1.Id,
            Status = MemberStatus.Active,
            MedicalNotes = "Previous right shoulder impingement in 2023. Cleared for all pressing movements."
        };

        var member2 = new Member
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            BranchId = branchDowntown.Id,
            MemberCode = "GIX-1002",
            FirstName = "Sophia",
            LastName = "Chen",
            Email = "sophia.chen@example.com",
            Phone = "+1 (555) 442-9901",
            Gender = "Female",
            DateOfBirth = new DateTime(1996, 8, 22),
            Address = "128 Beacon Hill Ave, Metropolis",
            EmergencyContactName = "Kevin Chen",
            EmergencyContactPhone = "+1 (555) 442-9902",
            JoiningDate = DateTime.UtcNow.AddMonths(-3),
            AssignedTrainerId = trainer1.Id,
            Status = MemberStatus.Active,
            MedicalNotes = "None reported. Excellent cardiovascular endurance."
        };

        var member3 = new Member
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            BranchId = branchDowntown.Id,
            MemberCode = "GIX-1003",
            FirstName = "Liam",
            LastName = "O'Connor",
            Email = "liam.oconnor@example.com",
            Phone = "+1 (555) 773-1245",
            Gender = "Male",
            DateOfBirth = new DateTime(1988, 11, 3),
            Address = "55 Marina Blvd, Apt 4B, Metropolis",
            EmergencyContactName = "Clara O'Connor",
            EmergencyContactPhone = "+1 (555) 773-1246",
            JoiningDate = DateTime.UtcNow.AddMonths(-10),
            AssignedTrainerId = null,
            Status = MemberStatus.Active,
            MedicalNotes = "Asthma (carries emergency inhaler in gym bag)."
        };

        var member4 = new Member
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            BranchId = branchWestside.Id,
            MemberCode = "GIX-1004",
            FirstName = "Olivia",
            LastName = "Martinez",
            Email = "olivia.m@example.com",
            Phone = "+1 (555) 882-6632",
            Gender = "Female",
            DateOfBirth = new DateTime(1994, 2, 19),
            Address = "901 Palm Canyon Rd, Westland",
            EmergencyContactName = "Carlos Martinez",
            EmergencyContactPhone = "+1 (555) 882-6633",
            JoiningDate = DateTime.UtcNow.AddMonths(-1),
            AssignedTrainerId = trainer2.Id,
            Status = MemberStatus.Active,
            MedicalNotes = null
        };

        var member5 = new Member
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            BranchId = branchDowntown.Id,
            MemberCode = "GIX-1005",
            FirstName = "Ethan",
            LastName = "Ramirez",
            Email = "ethan.r@example.com",
            Phone = "+1 (555) 661-4409",
            Gender = "Male",
            DateOfBirth = new DateTime(1990, 6, 30),
            Address = "310 Hudson St, Metropolis",
            EmergencyContactName = "Maria Ramirez",
            EmergencyContactPhone = "+1 (555) 661-4410",
            JoiningDate = DateTime.UtcNow.AddMonths(-8),
            AssignedTrainerId = null,
            Status = MemberStatus.Expired,
            MedicalNotes = null
        };

        var member6 = new Member
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            BranchId = branchWestside.Id,
            MemberCode = "GIX-1006",
            FirstName = "Ava",
            LastName = "Patel",
            Email = "ava.patel@example.com",
            Phone = "+1 (555) 554-3321",
            Gender = "Female",
            DateOfBirth = new DateTime(1998, 9, 12),
            Address = "88 Olympic Way, Westland",
            EmergencyContactName = "Raj Patel",
            EmergencyContactPhone = "+1 (555) 554-3322",
            JoiningDate = DateTime.UtcNow.AddMonths(-2),
            AssignedTrainerId = trainer2.Id,
            Status = MemberStatus.Frozen,
            MedicalNotes = "Temporary travel freeze until next month."
        };

        context.Members.AddRange(member1, member2, member3, member4, member5, member6);

        // 7. Member Subscriptions
        var sub1 = new MemberSubscription
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            MemberId = member1.Id,
            MembershipPlanId = planAnnual.Id,
            StartDate = DateTime.UtcNow.AddMonths(-6),
            EndDate = DateTime.UtcNow.AddMonths(6),
            PricePaid = 749.00m,
            DiscountAmount = 0.00m,
            Status = SubscriptionStatus.Active,
            Notes = "Paid in full via Card"
        };

        var sub2 = new MemberSubscription
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            MemberId = member2.Id,
            MembershipPlanId = planQuarterly.Id,
            StartDate = DateTime.UtcNow.AddMonths(-1),
            EndDate = DateTime.UtcNow.AddMonths(2),
            PricePaid = 219.00m,
            DiscountAmount = 0.00m,
            Status = SubscriptionStatus.Active,
            Notes = "Quarterly transformation enrollment"
        };

        var sub3 = new MemberSubscription
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            MemberId = member3.Id,
            MembershipPlanId = planMonthly.Id,
            StartDate = DateTime.UtcNow.AddDays(-15),
            EndDate = DateTime.UtcNow.AddDays(15),
            PricePaid = 79.00m,
            DiscountAmount = 0.00m,
            Status = SubscriptionStatus.Active,
            Notes = "Monthly auto-renew"
        };

        var sub4 = new MemberSubscription
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            MemberId = member4.Id,
            MembershipPlanId = planPT.Id,
            StartDate = DateTime.UtcNow.AddDays(-10),
            EndDate = DateTime.UtcNow.AddDays(50),
            PricePaid = 550.00m,
            DiscountAmount = 0.00m,
            Status = SubscriptionStatus.Active,
            Notes = "10 sessions with Elena"
        };

        context.MemberSubscriptions.AddRange(sub1, sub2, sub3, sub4);

        // 8. Financial Transactions
        var tx1 = new PaymentTransaction
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            BranchId = branchDowntown.Id,
            MemberId = member1.Id,
            SubscriptionId = sub1.Id,
            InvoiceNumber = "INV-2026-0001",
            Amount = 749.00m,
            PaymentMethod = PaymentMethod.Card,
            Status = PaymentStatus.Completed,
            TransactionReference = "CH_982347101",
            Notes = "Annual Elite All-Access Membership",
            CreatedAt = DateTime.UtcNow.AddMonths(-6)
        };

        var tx2 = new PaymentTransaction
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            BranchId = branchDowntown.Id,
            MemberId = member2.Id,
            SubscriptionId = sub2.Id,
            InvoiceNumber = "INV-2026-0002",
            Amount = 219.00m,
            PaymentMethod = PaymentMethod.UPI,
            Status = PaymentStatus.Completed,
            TransactionReference = "UPI_TXN_77412984",
            Notes = "Quarterly Plan Payment",
            CreatedAt = DateTime.UtcNow.AddMonths(-1)
        };

        var tx3 = new PaymentTransaction
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            BranchId = branchDowntown.Id,
            MemberId = member3.Id,
            SubscriptionId = sub3.Id,
            InvoiceNumber = "INV-2026-0003",
            Amount = 79.00m,
            PaymentMethod = PaymentMethod.Cash,
            Status = PaymentStatus.Completed,
            TransactionReference = "CSH_REC_4401",
            Notes = "Monthly Renewal Desk Cash Collection",
            CreatedAt = DateTime.UtcNow.AddDays(-15)
        };

        var tx4 = new PaymentTransaction
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            BranchId = branchWestside.Id,
            MemberId = member4.Id,
            SubscriptionId = sub4.Id,
            InvoiceNumber = "INV-2026-0004",
            Amount = 550.00m,
            PaymentMethod = PaymentMethod.BankTransfer,
            Status = PaymentStatus.Completed,
            TransactionReference = "WIRE_88931201",
            Notes = "Personal Training 10-Pack",
            CreatedAt = DateTime.UtcNow.AddDays(-10)
        };

        var tx5 = new PaymentTransaction
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            BranchId = branchDowntown.Id,
            MemberId = member2.Id,
            SubscriptionId = null,
            InvoiceNumber = "INV-2026-0005",
            Amount = 45.00m,
            PaymentMethod = PaymentMethod.Card,
            Status = PaymentStatus.Completed,
            TransactionReference = "CH_88239019",
            Notes = "Titan Whey Protein Tub + Shaker Bottle",
            CreatedAt = DateTime.UtcNow.AddDays(-2)
        };

        context.PaymentTransactions.AddRange(tx1, tx2, tx3, tx4, tx5);

        // 9. Attendance Records
        var today = DateTime.UtcNow.Date;
        var att1 = new AttendanceRecord
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            BranchId = branchDowntown.Id,
            MemberId = member1.Id,
            CheckInTime = today.AddHours(7).AddMinutes(15),
            CheckOutTime = today.AddHours(8).AddMinutes(45),
            Method = AttendanceMethod.QR,
            Notes = "Morning workout"
        };

        var att2 = new AttendanceRecord
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            BranchId = branchDowntown.Id,
            MemberId = member2.Id,
            CheckInTime = today.AddHours(8).AddMinutes(30),
            CheckOutTime = null, // currently working out
            Method = AttendanceMethod.Manual,
            Notes = "Front desk check-in"
        };

        var att3 = new AttendanceRecord
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            BranchId = branchWestside.Id,
            MemberId = member4.Id,
            CheckInTime = today.AddHours(9).AddMinutes(0),
            CheckOutTime = today.AddHours(10).AddMinutes(15),
            Method = AttendanceMethod.Manual,
            Notes = "PT session with Elena"
        };

        context.AttendanceRecords.AddRange(att1, att2, att3);

        // 10. CRM Leads
        var lead1 = new Lead
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            BranchId = branchDowntown.Id,
            FullName = "Lucas Vance",
            Email = "lucas.vance@example.com",
            Phone = "+1 (555) 712-4491",
            Source = LeadSource.Website,
            Stage = LeadStage.TrialScheduled,
            AssignedStaffId = manager.Id,
            Notes = "Interested in hypertrophy coaching and evening access.",
            NextFollowUpDate = DateTime.UtcNow.AddDays(1),
            EstimatedValue = 749.00m,
            CreatedAt = DateTime.UtcNow.AddDays(-4)
        };

        var lead2 = new Lead
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            BranchId = branchDowntown.Id,
            FullName = "Elena Morris",
            Email = "elena.m@example.com",
            Phone = "+1 (555) 890-1122",
            Source = LeadSource.WalkIn,
            Stage = LeadStage.Interested,
            AssignedStaffId = receptionist.Id,
            Notes = "Walked in for a club tour during lunch break. Very positive.",
            NextFollowUpDate = DateTime.UtcNow.AddDays(2),
            EstimatedValue = 219.00m,
            CreatedAt = DateTime.UtcNow.AddDays(-2)
        };

        var lead3 = new Lead
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            BranchId = branchWestside.Id,
            FullName = "Brandon Scott",
            Email = "bscott@example.com",
            Phone = "+1 (555) 441-2299",
            Source = LeadSource.SocialMedia,
            Stage = LeadStage.New,
            AssignedStaffId = null,
            Notes = "Filled Instagram lead form for 3-day guest trial.",
            NextFollowUpDate = DateTime.UtcNow.AddHours(4),
            EstimatedValue = 79.00m,
            CreatedAt = DateTime.UtcNow.AddHours(-3)
        };

        var lead4 = new Lead
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            BranchId = branchDowntown.Id,
            FullName = "Zoe Campbell",
            Email = "zoe.c@example.com",
            Phone = "+1 (555) 332-9018",
            Source = LeadSource.Referral,
            Stage = LeadStage.Converted,
            AssignedStaffId = manager.Id,
            Notes = "Referred by James Wilson. Signed up for Quarterly Plan!",
            NextFollowUpDate = null,
            EstimatedValue = 219.00m,
            CreatedAt = DateTime.UtcNow.AddDays(-10)
        };

        context.Leads.AddRange(lead1, lead2, lead3, lead4);

        // 11. Lead Activities
        var act1 = new LeadActivity
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            LeadId = lead1.Id,
            StaffId = manager.Id,
            ActivityType = "Call",
            Description = "Spoke with Lucas. Scheduled complimentary training trial for tomorrow 6 PM.",
            CreatedAt = DateTime.UtcNow.AddDays(-1)
        };

        var act2 = new LeadActivity
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            LeadId = lead2.Id,
            StaffId = receptionist.Id,
            ActivityType = "Tour",
            Description = "Completed 15-minute facility walkthrough including spa & free weights.",
            CreatedAt = DateTime.UtcNow.AddDays(-2)
        };
        context.LeadActivities.AddRange(act1, act2);

        // 12. Workout Plan
        var workoutPlan1 = new WorkoutPlan
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            MemberId = member1.Id,
            TrainerId = trainer1.Id,
            Title = "Upper/Lower Hypertrophy Split 4-Day",
            Goal = "Lean Muscle Hypertrophy & Barbell Strength",
            StartDate = DateTime.UtcNow.AddMonths(-1),
            EndDate = DateTime.UtcNow.AddMonths(2),
            Notes = "Focus on 2-second eccentric phase. Keep rest to 90 seconds on compound lifts.",
            ExercisesJson = @"[
                {
                    ""day"": ""Day 1: Upper Body Power"",
                    ""exercises"": [
                        {""name"": ""Barbell Bench Press"", ""sets"": 4, ""reps"": ""6-8"", ""rest"": ""120s""},
                        {""name"": ""Bent-Over Barbell Row"", ""sets"": 4, ""reps"": ""8-10"", ""rest"": ""90s""},
                        {""name"": ""Standing Overhead Press"", ""sets"": 3, ""reps"": ""8-10"", ""rest"": ""90s""},
                        {""name"": ""Incline Dumbbell Curl"", ""sets"": 3, ""reps"": ""12"", ""rest"": ""60s""}
                    ]
                },
                {
                    ""day"": ""Day 2: Lower Body Power"",
                    ""exercises"": [
                        {""name"": ""Barbell Back Squat"", ""sets"": 4, ""reps"": ""6-8"", ""rest"": ""120s""},
                        {""name"": ""Romanian Deadlift"", ""sets"": 3, ""reps"": ""8-10"", ""rest"": ""90s""},
                        {""name"": ""Leg Press"", ""sets"": 3, ""reps"": ""12"", ""rest"": ""90s""},
                        {""name"": ""Standing Calf Raise"", ""sets"": 4, ""reps"": ""15"", ""rest"": ""60s""}
                    ]
                }
            ]"
        };
        context.WorkoutPlans.Add(workoutPlan1);

        // 13. Seed WhatsApp Templates & Trigger Rules
        var tmplWelcome = new WhatsAppTemplate
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            Name = "welcome_onboarding",
            Category = "UTILITY",
            Header = "Welcome to Titan Fitness!",
            Body = "Welcome to Titan Fitness & Performance Club, {{1}}! Your {{2}} membership is active. Your assigned personal trainer is {{3}}. Let's build your fitness journey together.",
            Footer = "Titan Fitness Reception Desk",
            MetaStatus = "APPROVED",
            CreatedAt = DateTime.UtcNow.AddMonths(-3)
        };

        var tmplRenewal = new WhatsAppTemplate
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            Name = "membership_renewal_reminder",
            Category = "UTILITY",
            Header = "Membership Renewal Notice",
            Body = "Hi {{1}}, your {{2}} membership at Titan Fitness expires on {{3}}. Renew before expiry to maintain your locked-in rate without re-enrollment fees.",
            Footer = "Tap below to renew or reply here",
            MetaStatus = "APPROVED",
            CreatedAt = DateTime.UtcNow.AddMonths(-3)
        };

        var tmplPayment = new WhatsAppTemplate
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            Name = "payment_invoice_receipt",
            Category = "UTILITY",
            Header = "Payment Receipt",
            Body = "Hi {{1}}, we received your payment of ${{2}} for invoice {{3}}. Thank you for your continued dedication to your fitness goals.",
            Footer = "Download your official tax invoice anytime",
            MetaStatus = "APPROVED",
            CreatedAt = DateTime.UtcNow.AddMonths(-3)
        };

        var tmplInactivity = new WhatsAppTemplate
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            Name = "workout_streak_inactivity",
            Category = "MARKETING",
            Header = "We Miss You at the Gym!",
            Body = "Hey {{1}}, we noticed you haven't checked in for workout sessions this week. Consistency creates results! Need to adjust your routine or book coach time? Reply to chat with our front desk.",
            Footer = "Titan Fitness Wellness Team",
            MetaStatus = "APPROVED",
            CreatedAt = DateTime.UtcNow.AddMonths(-2)
        };

        context.WhatsAppTemplates.AddRange(tmplWelcome, tmplRenewal, tmplPayment, tmplInactivity);

        // WhatsApp Trigger Rules
        context.WhatsAppTriggerRules.AddRange(
            new WhatsAppTriggerRule { Id = Guid.NewGuid(), TenantId = tenant.Id, TriggerEvent = "OnPaymentCompleted", TemplateName = "payment_invoice_receipt", IsEnabled = true },
            new WhatsAppTriggerRule { Id = Guid.NewGuid(), TenantId = tenant.Id, TriggerEvent = "OnMembershipExpiring", TemplateName = "membership_renewal_reminder", IsEnabled = true },
            new WhatsAppTriggerRule { Id = Guid.NewGuid(), TenantId = tenant.Id, TriggerEvent = "OnMemberJoined", TemplateName = "welcome_onboarding", IsEnabled = true },
            new WhatsAppTriggerRule { Id = Guid.NewGuid(), TenantId = tenant.Id, TriggerEvent = "OnInactivity", TemplateName = "workout_streak_inactivity", IsEnabled = true }
        );

        // 14. Seed WhatsApp Conversational Messages with Members
        context.WhatsAppMessages.AddRange(
            // Conversation with James Wilson (member1)
            new WhatsAppMessage
            {
                Id = Guid.NewGuid(),
                TenantId = tenant.Id,
                BranchId = branchDowntown.Id,
                MemberId = member1.Id,
                RecipientPhone = member1.Phone,
                RecipientName = $"{member1.FirstName} {member1.LastName}",
                Direction = WhatsAppDirection.Outbound,
                MessageType = WhatsAppMessageType.Template,
                TemplateName = "welcome_onboarding",
                MessageContent = $"Welcome to Titan Fitness & Performance Club, James! Your Annual Elite Pro membership is active. Your assigned personal trainer is David Vance.",
                Status = WhatsAppMessageStatus.Read,
                SentAt = DateTime.UtcNow.AddDays(-10),
                DeliveredAt = DateTime.UtcNow.AddDays(-10).AddSeconds(2),
                ReadAt = DateTime.UtcNow.AddDays(-10).AddMinutes(5)
            },
            new WhatsAppMessage
            {
                Id = Guid.NewGuid(),
                TenantId = tenant.Id,
                BranchId = branchDowntown.Id,
                MemberId = member1.Id,
                RecipientPhone = member1.Phone,
                RecipientName = $"{member1.FirstName} {member1.LastName}",
                Direction = WhatsAppDirection.Inbound,
                MessageType = WhatsAppMessageType.Text,
                MessageContent = "Thank you! What time does the sauna and steam room close on weekdays?",
                Status = WhatsAppMessageStatus.Read,
                SentAt = DateTime.UtcNow.AddDays(-9),
                DeliveredAt = DateTime.UtcNow.AddDays(-9),
                ReadAt = DateTime.UtcNow.AddDays(-9).AddMinutes(1)
            },
            new WhatsAppMessage
            {
                Id = Guid.NewGuid(),
                TenantId = tenant.Id,
                BranchId = branchDowntown.Id,
                MemberId = member1.Id,
                RecipientPhone = member1.Phone,
                RecipientName = $"{member1.FirstName} {member1.LastName}",
                Direction = WhatsAppDirection.Outbound,
                MessageType = WhatsAppMessageType.Text,
                MessageContent = "Hi James, the spa amenities remain open until 10:30 PM Monday through Friday, and 8:00 PM on weekends. Let us know if you need locker reservations!",
                Status = WhatsAppMessageStatus.Read,
                SentAt = DateTime.UtcNow.AddDays(-9).AddMinutes(3),
                DeliveredAt = DateTime.UtcNow.AddDays(-9).AddMinutes(3).AddSeconds(2),
                ReadAt = DateTime.UtcNow.AddDays(-9).AddMinutes(4)
            },
            new WhatsAppMessage
            {
                Id = Guid.NewGuid(),
                TenantId = tenant.Id,
                BranchId = branchDowntown.Id,
                MemberId = member1.Id,
                RecipientPhone = member1.Phone,
                RecipientName = $"{member1.FirstName} {member1.LastName}",
                Direction = WhatsAppDirection.Outbound,
                MessageType = WhatsAppMessageType.Template,
                TemplateName = "payment_invoice_receipt",
                MessageContent = "Hi James, we received your payment of $749.00 for invoice INV-2026-0001. Thank you for your continued dedication to your fitness goals.",
                Status = WhatsAppMessageStatus.Read,
                SentAt = DateTime.UtcNow.AddDays(-2),
                DeliveredAt = DateTime.UtcNow.AddDays(-2).AddSeconds(1),
                ReadAt = DateTime.UtcNow.AddDays(-2).AddMinutes(12)
            },

            // Conversation with Sophia Chen (member2)
            new WhatsAppMessage
            {
                Id = Guid.NewGuid(),
                TenantId = tenant.Id,
                BranchId = branchDowntown.Id,
                MemberId = member2.Id,
                RecipientPhone = member2.Phone,
                RecipientName = $"{member2.FirstName} {member2.LastName}",
                Direction = WhatsAppDirection.Outbound,
                MessageType = WhatsAppMessageType.Template,
                TemplateName = "membership_renewal_reminder",
                MessageContent = "Hi Sophia, your Quarterly Transformation membership at Titan Fitness expires in 5 days. Renew before Nov 6 to maintain your locked-in rate without re-enrollment fees.",
                Status = WhatsAppMessageStatus.Delivered,
                SentAt = DateTime.UtcNow.AddHours(-4),
                DeliveredAt = DateTime.UtcNow.AddHours(-4).AddSeconds(3),
                ReadAt = null
            },
            new WhatsAppMessage
            {
                Id = Guid.NewGuid(),
                TenantId = tenant.Id,
                BranchId = branchDowntown.Id,
                MemberId = member2.Id,
                RecipientPhone = member2.Phone,
                RecipientName = $"{member2.FirstName} {member2.LastName}",
                Direction = WhatsAppDirection.Inbound,
                MessageType = WhatsAppMessageType.Text,
                MessageContent = "Can I renew with UPI online or do I have to pay at the desk?",
                Status = WhatsAppMessageStatus.Read,
                SentAt = DateTime.UtcNow.AddHours(-2),
                DeliveredAt = DateTime.UtcNow.AddHours(-2),
                ReadAt = DateTime.UtcNow.AddHours(-2).AddMinutes(1)
            },
            new WhatsAppMessage
            {
                Id = Guid.NewGuid(),
                TenantId = tenant.Id,
                BranchId = branchDowntown.Id,
                MemberId = member2.Id,
                RecipientPhone = member2.Phone,
                RecipientName = $"{member2.FirstName} {member2.LastName}",
                Direction = WhatsAppDirection.Outbound,
                MessageType = WhatsAppMessageType.Text,
                MessageContent = "You can pay via UPI directly from your member portal or at the front desk using our QR terminal. We have already generated your renewal invoice!",
                Status = WhatsAppMessageStatus.Delivered,
                SentAt = DateTime.UtcNow.AddHours(-1),
                DeliveredAt = DateTime.UtcNow.AddHours(-1).AddSeconds(2),
                ReadAt = null
            },

            // Conversation with Liam O'Connor (member3)
            new WhatsAppMessage
            {
                Id = Guid.NewGuid(),
                TenantId = tenant.Id,
                BranchId = branchDowntown.Id,
                MemberId = member3.Id,
                RecipientPhone = member3.Phone,
                RecipientName = $"{member3.FirstName} {member3.LastName}",
                Direction = WhatsAppDirection.Outbound,
                MessageType = WhatsAppMessageType.Template,
                TemplateName = "payment_invoice_receipt",
                MessageContent = "Hi Liam, payment of $79.00 received for monthly membership dues. Receipt #INV-2026-0003 is confirmed.",
                Status = WhatsAppMessageStatus.Read,
                SentAt = DateTime.UtcNow.AddDays(-1),
                DeliveredAt = DateTime.UtcNow.AddDays(-1).AddSeconds(1),
                ReadAt = DateTime.UtcNow.AddDays(-1).AddMinutes(2)
            }
        );

        // 13. Seed WhatsApp Integration & Consent
        context.WhatsAppIntegrations.Add(new WhatsAppIntegration
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            WabaId = "109283746592837",
            PhoneNumberId = "105938472910482",
            DisplayPhoneNumber = "+1 (555) 234-9428",
            BusinessPortfolioName = "Titan Performance & Fitness LLC",
            AccessToken = "EAAG_LIVE_SYSTEM_USER_TOKEN_METACLOUD_SECURE",
            ConnectionStatus = WhatsAppConnectionStatus.Connected,
            HealthStatus = "HEALTHY",
            TimeZoneId = "Asia/Kolkata",
            LastSyncedAt = DateTime.UtcNow
        });

        context.WhatsAppConsents.AddRange(
            new WhatsAppConsent { TenantId = tenant.Id, MemberId = member1.Id, Phone = member1.Phone, HasConsented = true, ConsentSource = "Digital Enrollment Agreement" },
            new WhatsAppConsent { TenantId = tenant.Id, MemberId = member2.Id, Phone = member2.Phone, HasConsented = true, ConsentSource = "Digital Enrollment Agreement" },
            new WhatsAppConsent { TenantId = tenant.Id, MemberId = member3.Id, Phone = member3.Phone, HasConsented = true, ConsentSource = "Digital Enrollment Agreement" }
        );

        // 14. Seed Exercise Categories
        var catStrength = new ExerciseCategory { TenantId = tenant.Id, Name = "Strength Training", Description = "Hypertrophy and progressive overload lifting", IconName = "dumbbell" };
        var catCardio = new ExerciseCategory { TenantId = tenant.Id, Name = "Cardio & HIIT", Description = "Cardiovascular conditioning and interval sprints", IconName = "heart-pulse" };
        var catCore = new ExerciseCategory { TenantId = tenant.Id, Name = "Core & Trunk", Description = "Abdominal stability and posterior chain support", IconName = "shield" };
        var catMobility = new ExerciseCategory { TenantId = tenant.Id, Name = "Mobility & Flexibility", Description = "Joint decompression and active range of motion", IconName = "activity" };
        context.ExerciseCategories.AddRange(catStrength, catCardio, catCore, catMobility);

        // 15. Seed Exercises
        var exBench = new Exercise
        {
            TenantId = tenant.Id,
            Name = "Barbell Bench Press",
            Category = "Strength",
            TargetMuscle = "Chest",
            SecondaryMusclesJson = "[\"Triceps\", \"Anterior Deltoids\"]",
            Equipment = "Barbell & Flat Bench",
            DifficultyLevel = FitnessLevel.Intermediate,
            Instructions = "Retract scapulae firmly onto bench. Lower bar with controlled cadence to mid-sternum, then press vertically with explosive intent.",
            DefaultSets = 4,
            DefaultReps = "8-10",
            DefaultRestSeconds = 90,
            SafetyNotes = "Always utilize spotter or safety pins when performing near-failure sets."
        };

        var exSquat = new Exercise
        {
            TenantId = tenant.Id,
            Name = "Barbell Back Squat",
            Category = "Strength",
            TargetMuscle = "Legs",
            SecondaryMusclesJson = "[\"Quadriceps\", \"Glutes\", \"Hamstrings\", \"Spinal Erectors\"]",
            Equipment = "Barbell & Squat Rack",
            DifficultyLevel = FitnessLevel.Intermediate,
            Instructions = "Place bar firmly across upper traps. Inhale into abdominal brace, break at hips and knees simultaneously to depth below parallel.",
            DefaultSets = 4,
            DefaultReps = "6-8",
            DefaultRestSeconds = 120,
            SafetyNotes = "Maintain rigid spinal alignment throughout entire concentric arc."
        };

        var exDeadlift = new Exercise
        {
            TenantId = tenant.Id,
            Name = "Barbell Deadlift",
            Category = "Strength",
            TargetMuscle = "Back",
            SecondaryMusclesJson = "[\"Hamstrings\", \"Glutes\", \"Lats\", \"Trapezius\"]",
            Equipment = "Olympic Barbell & Bumper Plates",
            DifficultyLevel = FitnessLevel.Advanced,
            Instructions = "Stand with mid-foot beneath barbell. Hinge hips backwards, grip bar outside shins, pull chest tall to set lats, push floor away.",
            DefaultSets = 3,
            DefaultReps = "5",
            DefaultRestSeconds = 180,
            SafetyNotes = "Do not round the lumbar spine during the initial pull off the platform."
        };

        var exOverheadPress = new Exercise
        {
            TenantId = tenant.Id,
            Name = "Standing Overhead Press",
            Category = "Strength",
            TargetMuscle = "Shoulders",
            SecondaryMusclesJson = "[\"Triceps\", \"Upper Chest\", \"Core\"]",
            Equipment = "Barbell",
            DifficultyLevel = FitnessLevel.Intermediate,
            Instructions = "Grip barbell just outside shoulder width. Squeeze glutes and quads, press bar vertically clearing chin, lock elbows overhead.",
            DefaultSets = 3,
            DefaultReps = "8-10",
            DefaultRestSeconds = 90
        };

        var exPlank = new Exercise
        {
            TenantId = tenant.Id,
            Name = "Forearm Plank with Hip Dips",
            Category = "Core",
            TargetMuscle = "Core",
            SecondaryMusclesJson = "[\"Obliques\", \"Transverse Abdominis\"]",
            Equipment = "Fitness Mat",
            DifficultyLevel = FitnessLevel.Beginner,
            Instructions = "Hold solid neutral plank on forearms. Gently rotate hips from side to side tapping mat lightly while maintaining core stiffness.",
            DefaultSets = 3,
            DefaultReps = "12 per side",
            DefaultRestSeconds = 60,
            DurationSeconds = 45
        };

        var exHiit = new Exercise
        {
            TenantId = tenant.Id,
            Name = "Sprint Treadmill Intervals",
            Category = "Cardio",
            TargetMuscle = "Full Body",
            SecondaryMusclesJson = "[\"Calves\", \"Hamstrings\", \"Cardiovascular\"]",
            Equipment = "Commercial Treadmill",
            DifficultyLevel = FitnessLevel.Intermediate,
            Instructions = "Warm up 3 minutes at 5 km/h. Sprint 30 seconds at 14 km/h followed by 30 seconds walk recovery at 4 km/h for 10 rounds.",
            DefaultSets = 10,
            DefaultReps = "30s sprint / 30s rest",
            DefaultRestSeconds = 30,
            DurationSeconds = 600
        };

        context.Exercises.AddRange(exBench, exSquat, exDeadlift, exOverheadPress, exPlank, exHiit);

        // 16. Seed Workout Templates
        var templateHypertrophy = new WorkoutTemplate
        {
            TenantId = tenant.Id,
            Title = "4-Day Hypertrophy & Strength Split",
            Description = "Classic Upper/Lower high-yield muscle development protocol designed for intermediate lifters.",
            Goal = "Muscle Building",
            Level = FitnessLevel.Intermediate,
            DaysPerWeek = 4,
            EstimatedMinutesPerSession = 55,
            RoutineJson = "[{\"day\":\"Monday\",\"routineTitle\":\"Upper Push & Delts\",\"exercises\":[{\"name\":\"Barbell Bench Press\",\"sets\":4,\"reps\":\"8-10\",\"rest\":\"90s\"},{\"name\":\"Standing Overhead Press\",\"sets\":3,\"reps\":\"10\",\"rest\":\"90s\"}]},{\"day\":\"Tuesday\",\"routineTitle\":\"Lower Quad & Core\",\"exercises\":[{\"name\":\"Barbell Back Squat\",\"sets\":4,\"reps\":\"6-8\",\"rest\":\"120s\"},{\"name\":\"Forearm Plank with Hip Dips\",\"sets\":3,\"reps\":\"12 per side\",\"rest\":\"60s\"}]}]",
            CreatedAt = DateTime.UtcNow.AddMonths(-3)
        };

        var templateFatLoss = new WorkoutTemplate
        {
            TenantId = tenant.Id,
            Title = "Fat Loss & Metabolic Conditioning",
            Description = "Fast-paced compound circuits combined with HIIT sprint conditioning to maximize caloric expenditure.",
            Goal = "Fat Loss & Conditioning",
            Level = FitnessLevel.Beginner,
            DaysPerWeek = 5,
            EstimatedMinutesPerSession = 40,
            RoutineJson = "[{\"day\":\"Monday\",\"routineTitle\":\"Full Body Metabolic Circuit\",\"exercises\":[{\"name\":\"Barbell Back Squat\",\"sets\":3,\"reps\":\"12\",\"rest\":\"60s\"},{\"name\":\"Sprint Treadmill Intervals\",\"sets\":8,\"reps\":\"30s/30s\",\"rest\":\"30s\"}]}]",
            CreatedAt = DateTime.UtcNow.AddMonths(-2)
        };
        context.WorkoutTemplates.AddRange(templateHypertrophy, templateFatLoss);

        // 17. Seed Member Workout Schedules
        context.MemberWorkoutSchedules.AddRange(
            new MemberWorkoutSchedule
            {
                TenantId = tenant.Id,
                MemberId = member1.Id,
                WorkoutTemplateId = templateHypertrophy.Id,
                AssignedTrainerId = trainer1.Id,
                DayOfWeek = "Monday",
                ScheduledDeliveryTime = "07:00",
                RoutineTitle = "Chest & Delts Hypertrophy",
                ExercisesJson = "[{\"name\":\"Barbell Bench Press\",\"sets\":4,\"reps\":\"8-10\",\"rest\":\"90s\"},{\"name\":\"Standing Overhead Press\",\"sets\":3,\"reps\":\"10\",\"rest\":\"90s\"}]",
                IsRestDay = false,
                TrainerApproved = true,
                IsActive = true,
                TrainerNotes = "Focus on a clean 2-second eccentric lowering phase today."
            },
            new MemberWorkoutSchedule
            {
                TenantId = tenant.Id,
                MemberId = member1.Id,
                WorkoutTemplateId = templateHypertrophy.Id,
                AssignedTrainerId = trainer1.Id,
                DayOfWeek = "Tuesday",
                ScheduledDeliveryTime = "07:00",
                RoutineTitle = "Lower Body Squat & Posterior Chain",
                ExercisesJson = "[{\"name\":\"Barbell Back Squat\",\"sets\":4,\"reps\":\"6-8\",\"rest\":\"120s\"},{\"name\":\"Forearm Plank with Hip Dips\",\"sets\":3,\"reps\":\"12 per side\",\"rest\":\"60s\"}]",
                IsRestDay = false,
                TrainerApproved = true,
                IsActive = true
            },
            new MemberWorkoutSchedule
            {
                TenantId = tenant.Id,
                MemberId = member1.Id,
                DayOfWeek = "Wednesday",
                ScheduledDeliveryTime = "08:00",
                RoutineTitle = "Mid-Week Active Recovery",
                ExercisesJson = "[]",
                IsRestDay = true,
                TrainerApproved = true,
                IsActive = true,
                TrainerNotes = "Aim for 8,000 steps of light walking and gentle stretching."
            }
        );

        // 18. Seed Member Fitness Baseline & Measurements
        var baseline1 = new MemberFitnessBaseline
        {
            TenantId = tenant.Id,
            MemberId = member1.Id,
            InitialWeightKg = 84.50m,
            HeightCm = 178.00m,
            InitialBmi = 26.67m,
            InitialMeasurementDate = DateTime.UtcNow.AddMonths(-6).Date,
            FitnessGoal = "Lean Muscle Hypertrophy & Fat Reduction",
            FitnessLevel = FitnessLevel.Intermediate,
            TrainingFrequencyDaysPerWeek = 4,
            MedicalAndDietNotes = "High protein diet target (160g/day). Avoiding excessive heavy overhead presses due to prior right shoulder history."
        };
        context.MemberFitnessBaselines.Add(baseline1);

        context.MemberMeasurements.AddRange(
            new MemberMeasurement
            {
                TenantId = tenant.Id,
                MemberId = member1.Id,
                WeightKg = 84.50m,
                HeightCm = 178.00m,
                CalculatedBmi = 26.67m,
                WaistCm = 93.00m,
                ChestCm = 104.00m,
                HipCm = 102.00m,
                LeftArmCm = 36.50m,
                RightArmCm = 37.00m,
                BodyFatPercentage = 22.4m,
                MeasurementDate = DateTime.UtcNow.AddMonths(-6).Date,
                Notes = "Initial onboarding intake assessment.",
                WeightDifferenceKg = 0.00m,
                WeightChangePercent = 0.00m
            },
            new MemberMeasurement
            {
                TenantId = tenant.Id,
                MemberId = member1.Id,
                WeightKg = 82.20m,
                HeightCm = 178.00m,
                CalculatedBmi = 25.94m,
                WaistCm = 89.50m,
                ChestCm = 105.00m,
                HipCm = 100.50m,
                LeftArmCm = 37.00m,
                RightArmCm = 37.20m,
                BodyFatPercentage = 19.8m,
                MeasurementDate = DateTime.UtcNow.AddMonths(-3).Date,
                Notes = "Month 3 progress check-in. Significant waist reduction and noticeable strength gain on bench press.",
                WeightDifferenceKg = -2.30m,
                WeightChangePercent = -2.72m
            },
            new MemberMeasurement
            {
                TenantId = tenant.Id,
                MemberId = member1.Id,
                WeightKg = 79.80m,
                HeightCm = 178.00m,
                CalculatedBmi = 25.19m,
                WaistCm = 85.00m,
                ChestCm = 106.50m,
                HipCm = 98.00m,
                LeftArmCm = 38.00m,
                RightArmCm = 38.20m,
                BodyFatPercentage = 16.5m,
                MeasurementDate = DateTime.UtcNow.AddDays(-5).Date,
                Notes = "Recent comprehensive review. Reached sub-80kg milestone with increased arm circumference!",
                WeightDifferenceKg = -4.70m,
                WeightChangePercent = -5.56m
            }
        );

        // 19. Seed Onboarding Journey
        context.MemberOnboardingJourneys.Add(new MemberOnboardingJourney
        {
            TenantId = tenant.Id,
            MemberId = member1.Id,
            RegistrationCompleted = true,
            RegistrationCompletedAt = DateTime.UtcNow.AddMonths(-6),
            ConsentCollected = true,
            ConsentCollectedAt = DateTime.UtcNow.AddMonths(-6),
            WelcomeSent = true,
            WelcomeSentAt = DateTime.UtcNow.AddMonths(-6),
            AssessmentCompleted = true,
            AssessmentCompletedAt = DateTime.UtcNow.AddMonths(-6).AddDays(1),
            InitialMeasurementDone = true,
            InitialMeasurementDoneAt = DateTime.UtcNow.AddMonths(-6).AddDays(1),
            TrainerAssigned = true,
            TrainerAssignedAt = DateTime.UtcNow.AddMonths(-6).AddDays(2),
            WorkoutPlanAssigned = true,
            WorkoutPlanAssignedAt = DateTime.UtcNow.AddMonths(-6).AddDays(2),
            FirstWorkoutDelivered = true,
            FirstWorkoutDeliveredAt = DateTime.UtcNow.AddMonths(-6).AddDays(3),
            FirstWeekReviewDone = true,
            FirstWeekReviewDoneAt = DateTime.UtcNow.AddMonths(-6).AddDays(10),
            Notes = "Completed full onboarding with flying colors."
        });

        await context.SaveChangesAsync();
    }
}

