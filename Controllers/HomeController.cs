using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;
using System.Xml;
using System.Xml.Schema;
using System.Xml.Xsl;
using XmlXsltWeb.Models;

namespace XmlXsltWeb.Controllers
{
    public class HomeController : Controller
    {
        private readonly IWebHostEnvironment _env;

        public HomeController(IWebHostEnvironment env)
        {
            _env = env;
        }

        public IActionResult Index()
        {
            return View();
        }

        public IActionResult Privacy()
        {
            return View();
        }

        public IActionResult Teoria()
        {
            return View();
        }

        // Isoleveta.xml + XSLTFile.xslt -> HTML
        public IActionResult Isoleveta()
        {
            ViewData["Title"] = "Sugupuu (XML + XSLT)";
            return Sugupuu("Isoleveta.xml");
        }

        // MinuSugupuu.xml + XSLTFile.xslt -> HTML
        public IActionResult MinuSugupuu()
        {
            ViewData["Title"] = "Minu sugupuu";
            return Sugupuu("MinuSugupuu.xml");
        }

        private IActionResult Sugupuu(string xmlFail)
        {
            string xmlPath = Path.Combine(_env.ContentRootPath, xmlFail);
            string xsltPath = Path.Combine(_env.ContentRootPath, "XSLTFile.xslt");

            var xslt = new XslCompiledTransform();
            xslt.Load(xsltPath);

            var parameetrid = new XsltArgumentList();
            parameetrid.AddParam("aasta", "", DateTime.Now.Year);

            using var tulemus = new StringWriter();
            xslt.Transform(xmlPath, parameetrid, tulemus);

            ViewBag.XmlFail = xmlFail;
            ViewBag.Tulemus = tulemus.ToString();
            return View("Isoleveta");
        }

        // wwwroot/lib/Reis.xml + wwwroot/lib/reisidParing.xslt -> HTML (teisendus toimub vaates)
        public IActionResult Reisid()
        {
            return View();
        }

        // MinuSugupuu.xml valideerimine skeemi Isoleveta.xsd vastu
        public IActionResult Validation()
        {
            string xmlPath = Path.Combine(_env.ContentRootPath, "MinuSugupuu.xml");
            string xsdPath = Path.Combine(_env.ContentRootPath, "Isoleveta.xsd");

            var vead = new List<string>();
            var seaded = new XmlReaderSettings { ValidationType = ValidationType.Schema };
            seaded.ValidationFlags |= XmlSchemaValidationFlags.ReportValidationWarnings;
            seaded.Schemas.Add(null, xsdPath);
            seaded.ValidationEventHandler += (sender, e) =>
                vead.Add($"Rida {e.Exception.LineNumber}, veerg {e.Exception.LinePosition}: {e.Message}");

            try
            {
                using var lugeja = XmlReader.Create(xmlPath, seaded);
                while (lugeja.Read()) { }
            }
            catch (XmlException ex)
            {
                vead.Add($"Rida {ex.LineNumber}, veerg {ex.LinePosition}: {ex.Message}");
            }

            ViewBag.Vead = vead;
            ViewBag.Xsd = System.IO.File.ReadAllText(xsdPath);
            ViewBag.XmlFail = "MinuSugupuu.xml";
            ViewBag.Xml = System.IO.File.ReadAllText(xmlPath);
            ViewBag.Ekraanipilt = System.IO.File.Exists(Path.Combine(_env.WebRootPath, "images", "valideerimine.png"));
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}
