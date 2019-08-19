package org.peterpro;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.InputStream;
import java.io.IOException;

import java.util.Comparator;
import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;

import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;

import javax.xml.transform.Templates;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import net.sf.saxon.value.StringValue;

import org.apache.commons.io.IOUtils;

import com.google.common.hash.Hashing;

/**
 * TransformerServlet. Transform supplied XML with XSLT, using supplied
 * parameters, with caching of results.
 */
@SuppressWarnings("serial")
@MultipartConfig
public final class TransformerServlet extends HttpServlet {

    @Override
    protected void doPost(
            final HttpServletRequest request,
            final HttpServletResponse response)
        throws ServletException, IOException {

        response.setHeader("Access-Control-Allow-Origin", "*");

        ServletOutputStream out = response.getOutputStream();

        Part xmlPart = request.getPart("__xml");
        InputStream xmlContent = xmlPart.getInputStream();
        final byte[] xmlBytes = IOUtils.toByteArray(xmlContent);

        final String xslID = request.getParameter("__xslID");

        // only take first value for each parameter name
        final Map<String, String> xsltParams = request.getParameterMap()
            .entrySet()
            .stream()
            .filter(e -> !e.getKey().startsWith("__"))
            .collect(Collectors.toMap(Map.Entry::getKey, e -> e.getValue()[0]));

        try {
            out.write(getResult(xslID, xsltParams, xmlBytes));
        } catch (TransformerException err) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.println(err.getMessage());
            err.printStackTrace();
        }
    }

    @Override
    protected void doOptions(
            final HttpServletRequest request,
            final HttpServletResponse response)
        throws ServletException, IOException {

        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "POST");
        response.setStatus(HttpServletResponse.SC_OK);
    }

    @Override
    public void init() throws ServletException {
        System.setProperty("javax.xml.transform.TransformerFactory",
                           "net.sf.saxon.TransformerFactoryImpl");
        System.out.println(
                "Servlet " + this.getServletName() + " has started");
    }

    @Override
    public void destroy() {
        System.out.println("Servlet " + this.getServletName() + " has stopped");
    }

    /**
    * Maintain prepared stylesheets in memory for reuse.
    *
    * @param stylesheetID stylesheet ID
    * @return Templates corresponding to the supplied ID
    * @throws javax.xml.transform.TransformerException if something goes wrong
    */
    private synchronized Templates getTemplates(final String stylesheetID)
        throws TransformerException {

        Templates templates = templatesCache.get(stylesheetID);
        if (templates != null) {
            return templates;
        }

        final String filename = "WEB-INF/xsl/" + stylesheetID + ".xsl";
        final String path = getServletContext().getRealPath(filename);
        if (path == null) {
            throw new TransformerException(
                    "Stylesheet " + filename + " not found");
        }

        TransformerFactory factory = TransformerFactory.newInstance();
        templates = factory.newTemplates(new StreamSource(new File(path)));
        templatesCache.put(stylesheetID, templates);
        return templates;
    }

    /**
    * Cache XSLT results in memory.
    *
    * @param xslID stylesheet ID
    * @param xsltParams XSLT params map
    * @param xmlBytes XML data
    * @return resulting bytes
    * @throws javax.xml.transform.TransformerException if something goes wrong
    */
    private synchronized byte[] getResult(
            final String xslID,
            final Map<String, String> xsltParams,
            final byte[] xmlBytes)
        throws TransformerException {

        final String xmlHash = Hashing.sha256().hashBytes(xmlBytes).toString();
        final String paramsRepr = xsltParams
            .entrySet()
            .stream()
            .sorted(Comparator.comparing(e -> e.getKey()))
            .map(e -> e.getKey() + "=" + e.getValue())
            .collect(Collectors.joining(";;"));
        final String resultKey = xslID + "::" + xmlHash + "::" + paramsRepr;

        final byte[] cachedResult = resultCache.get(resultKey);
        if (cachedResult != null) {
            return cachedResult;
        } else {
            Templates templates = getTemplates(xslID);
            Transformer transformer = templates.newTransformer();
            xsltParams
                .entrySet()
                .forEach(e ->
                    transformer.setParameter(
                        e.getKey(),
                        new StringValue(e.getValue())));
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            transformer.transform(
                new StreamSource(new ByteArrayInputStream(xmlBytes)),
                new StreamResult(baos));
            final byte[] result = baos.toByteArray();
            resultCache.put(resultKey, result);
            return result;
        }
    }

    /**
     * Maximum number of prepared stylesheets to cache.
     */
    static final int STYLESHEET_CACHE_SIZE = 8;

    /**
     * Maximum number of transformation results to cache.
     */
    static final int RESULT_CACHE_SIZE = 512;

    /**
     * Stylesheet cache.
     */
    private HashMap<String, Templates> templatesCache =
        new HashMap<String, Templates>(STYLESHEET_CACHE_SIZE);

    /**
     * Result cache.
     */
    private HashMap<String, byte[]> resultCache =
        new HashMap<String, byte[]>(RESULT_CACHE_SIZE);
}
