
<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}" class="dark">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Zidni - The Context-First Super App</title>
    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=inter:400,500,600,700,800,900" rel="stylesheet" />
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #0a0a0a;
            color: #ededec;
        }
        .noise {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            pointer-events: none;
            opacity: 0.05;
            background-image: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100"><filter id="noise"><feTurbulence type="fractalNoise" baseFrequency="0.65" numOctaves="3" stitchTiles="stitch"/></filter><rect width="100%" height="100%" filter="url(%23noise)"/></svg>');
        }
        .glow-button {
            box-shadow: 0 0 15px rgba(246, 21, 0, 0.4), 0 0 30px rgba(246, 21, 0, 0.3), 0 0 45px rgba(246, 21, 0, 0.2);
        }
        .card {
            background-color: rgba(22, 22, 21, 0.8);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.37);
        }
        .hero-gradient-text {
            background: -webkit-linear-gradient(45deg, #F61500, #FF750F);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
    </style>
</head>
<body class="antialiased">
    <div class="noise"></div>
    <div class="relative min-h-screen flex flex-col items-center justify-center px-4 sm:px-6 lg:px-8">

        <header class="w-full max-w-7xl mx-auto py-6 flex justify-between items-center">
            <h1 class="text-3xl font-bold hero-gradient-text">ZIDNI</h1>
            <nav>
                <a href="#features" class="text-lg font-medium text-gray-300 hover:text-white transition-colors">Features</a>
                <a href="#about" class="ml-6 text-lg font-medium text-gray-300 hover:text-white transition-colors">About</a>
                <a href="#contact" class="ml-6 text-lg font-medium text-gray-300 hover:text-white transition-colors">Contact</a>
            </nav>
        </header>

        <main class="w-full max-w-7xl mx-auto text-center my-auto">
            <h1 class="text-5xl md:text-7xl font-extrabold tracking-tighter mb-4">The Operating System for the <span class="hero-gradient-text">Arab Economy</span></h1>
            <p class="max-w-3xl mx-auto text-lg md:text-xl text-gray-400 mb-8">
                Zidni is a "Context-First" Super App for the MENA Region, built on a "Zero UI" and "Zero Commission" philosophy. We are creating a decentralized network to empower the invisible economy.
            </p>
            <button class="bg-red-600 text-white font-bold py-3 px-8 rounded-full text-lg glow-button transform hover:scale-105 transition-transform">
                Get Early Access
            </button>
        </main>

        <section id="features" class="w-full max-w-7xl mx-auto py-20">
            <h2 class="text-4xl font-bold text-center mb-12">A Revolution in <span class="hero-gradient-text">Capability & Logistics</span></h2>
            <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
                <div class="card p-8 rounded-2xl">
                    <h3 class="text-2xl font-bold mb-4">KYC-apability & The Mesh</h3>
                    <p class="text-gray-400">We're redefining KYC. Instead of just "Who are you?", we verify "What can you do?" and "What do you own?". This creates the Zidni Mesh, a real-time human radar connecting needs with verified capabilities.</p>
                </div>
                <div class="card p-8 rounded-2xl">
                    <h3 class="text-2xl font-bold mb-4">Logistics Revolution</h3>
                    <p class="text-gray-400">We're disrupting the gig economy by unlocking the "Invisible Fleet". Drivers utilize their empty legs for passengers or packages, keeping 100% of the revenue through a subscription model.</p>
                </div>
                <div class="card p-8 rounded-2xl">
                    <h3 class="text-2xl font-bold mb-4">Zidni Flow & Hybrid UI</h3>
                    <p class="text-gray-400">Moving beyond static icons. Our predictive, context-aware UI stream shows you what you need, when you need it. A seamless experience powered by AI and Zero UI principles.</p>
                </div>
            </div>
        </section>

        <footer id="contact" class="w-full max-w-7xl mx-auto py-12 text-center text-gray-500">
            <p>&copy; {{ date('Y') }} Zidni. All rights reserved.</p>
            <div class="mt-4">
                <a href="#" class="hover:text-white transition-colors">Privacy Policy</a>
                <span class="mx-2">|</span>
                <a href="#" class="hover:text-white transition-colors">Terms of Service</a>
            </div>
        </footer>

    </div>
</body>
</html>
